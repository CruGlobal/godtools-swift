//
//  TempURLSessionWebSocket.swift
//  godtools
//
//  Created by Levi Eggert on 8/14/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RequestOperation

// MARK: - Events

enum WebSocketEvent: Sendable {
    case didConnect
    case didReceiveText(text: String)
    case didDisconnect(reason: WebSocketDisconnectReason)
}

enum WebSocketDisconnectReason: Sendable {
    case userInitiated
    case closedByServer(closeCode: URLSessionWebSocketTask.CloseCode, reason: String?)
    case failed(error: WebSocketError)
}

enum WebSocketError: Error, Sendable {
    case notConnected
    case transportFailed(description: String)
}

// MARK: - Interface

protocol AsyncWebSocketInterface: Sendable {

    var url: URL { get }
    var connectionState: WebSocketConnectionState { get async }

    init(url: URL)

    func events() async -> AsyncStream<WebSocketEvent>
    func connect() async throws
    func disconnect() async
    func write(string: String) async throws
}

// MARK: - TempURLSessionWebSocket

actor TempURLSessionWebSocket: AsyncWebSocketInterface {

    private let session: URLSession
    private let keepSocketAlive: KeepWebSocketAlive = KeepWebSocketAlive()
    private let messagesObserver: WebSocketMessagesObserver = WebSocketMessagesObserver()

    private var eventContinuations: [UUID: AsyncStream<WebSocketEvent>.Continuation] = Dictionary()
    private var connectContinuations: [CheckedContinuation<Void, any Error>] = Array()
    private var currentWebSocketTask: URLSessionWebSocketTask?
    private var currentTaskDelegate: URLSessionWebSocketTaskDelegate?
    private var receiveMessagesTask: Task<Void, Never>?

    private(set) var connectionState: WebSocketConnectionState = .disconnected

    let url: URL

    init(url: URL) {

        self.url = url
        self.session = URLSession(configuration: CreateIgnoreCacheSessionConfig().createConfig())
    }

    deinit {
        session.invalidateAndCancel()
    }

    // MARK: - Events

    func events() -> AsyncStream<WebSocketEvent> {

        let continuationId: UUID = UUID()

        return AsyncStream { (continuation: AsyncStream<WebSocketEvent>.Continuation) in

            eventContinuations[continuationId] = continuation

            continuation.onTermination = { [weak self] _ in
                Task { [weak self] in
                    await self?.removeEventContinuation(continuationId: continuationId)
                }
            }
        }
    }

    private func removeEventContinuation(continuationId: UUID) {
        eventContinuations[continuationId] = nil
    }

    private func yieldEvent(event: WebSocketEvent) {

        for continuation in eventContinuations.values {
            continuation.yield(event)
        }
    }

    // MARK: - Connecting

    func connect() async throws {

        switch connectionState {

        case .connected:
            return

        case .connecting:
            try await waitForConnection()
            return

        case .disconnected:
            break
        }

        connectionState = .connecting

        let taskDelegate: URLSessionWebSocketTaskDelegate = URLSessionWebSocketTaskDelegate(
            didOpen: { [weak self] in
                Task { await self?.handleDidOpen() }
            },
            didClose: { [weak self] (closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) in
                Task { await self?.handleDidClose(closeCode: closeCode, reason: reason) }
            },
            didComplete: { [weak self] (error: (any Error)?) in
                Task { await self?.handleDidComplete(error: error) }
            }
        )

        let webSocketTask: URLSessionWebSocketTask = session.webSocketTask(with: url)

        webSocketTask.delegate = taskDelegate

        currentTaskDelegate = taskDelegate
        currentWebSocketTask = webSocketTask

        webSocketTask.resume()

        // NOTE: There is no suspension point between resume() and awaiting below, so delegate callbacks can't be handled before this continuation is registered. ~Levi
        try await waitForConnection()
    }

    private func waitForConnection() async throws {

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
            connectContinuations.append(continuation)
        }
    }

    private func resumeConnectContinuations(result: Result<Void, any Error>) {

        let continuations: [CheckedContinuation<Void, any Error>] = connectContinuations

        connectContinuations = Array()

        for continuation in continuations {
            continuation.resume(with: result)
        }
    }

    // MARK: - Disconnecting

    func disconnect() async {
        await disconnect(reason: .userInitiated)
    }

    private func disconnect(reason: WebSocketDisconnectReason) async {

        guard connectionState != .disconnected else {
            return
        }

        connectionState = .disconnected

        receiveMessagesTask?.cancel()
        receiveMessagesTask = nil

        currentWebSocketTask?.cancel(with: .goingAway, reason: nil)
        currentWebSocketTask = nil
        currentTaskDelegate = nil

        resumeConnectContinuations(result: .failure(WebSocketError.notConnected))

        yieldEvent(event: .didDisconnect(reason: reason))

        await messagesObserver.stop()
        await keepSocketAlive.stop()
    }

    // MARK: - Writing

    func write(string: String) async throws {

        guard connectionState == .connected, let webSocketTask = currentWebSocketTask else {
            throw WebSocketError.notConnected
        }

        do {
            try await webSocketTask.send(.string(string))
        }
        catch {
            throw WebSocketError.transportFailed(description: error.localizedDescription)
        }
    }

    // MARK: - Receiving

    private func startReceivingMessages(webSocketTask: URLSessionWebSocketTask) async {

        let messages: AsyncThrowingStream<String, any Error> = await messagesObserver.start(webSocketTask: webSocketTask)

        receiveMessagesTask = Task { [weak self] in

            do {

                for try await text in messages {

                    guard let self = self else {
                        return
                    }

                    await self.handleTextReceived(text: text)
                }
            }
            catch {

                guard let self = self else {
                    return
                }

                await self.handleReceiveFailed(error: error)
            }
        }
    }

    private func handleTextReceived(text: String) {
        yieldEvent(event: .didReceiveText(text: text))
    }

    private func handleReceiveFailed(error: any Error) async {

        guard connectionState != .disconnected else {
            return
        }

        await disconnect(reason: .failed(error: .transportFailed(description: error.localizedDescription)))
    }

    // MARK: - URLSessionWebSocketDelegate Handling

    private func handleDidOpen() async {

        guard connectionState == .connecting, let webSocketTask = currentWebSocketTask else {
            return
        }

        connectionState = .connected

        yieldEvent(event: .didConnect)

        resumeConnectContinuations(result: .success(()))

        await startReceivingMessages(webSocketTask: webSocketTask)
        await keepSocketAlive.start(webSocketTask: webSocketTask)

        // NOTE: A disconnect can interleave with the awaits above, so make sure nothing is left running for a socket that closed. ~Levi
        if connectionState != .connected {

            receiveMessagesTask?.cancel()
            receiveMessagesTask = nil

            await messagesObserver.stop()
            await keepSocketAlive.stop()
        }
    }

    private func handleDidClose(closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) async {

        let reasonText: String?

        if let reason = reason {
            reasonText = String(data: reason, encoding: .utf8)
        }
        else {
            reasonText = nil
        }

        await disconnect(reason: .closedByServer(closeCode: closeCode, reason: reasonText))
    }

    private func handleDidComplete(error: (any Error)?) async {

        guard connectionState != .disconnected else {
            return
        }

        guard let error = error else {
            await disconnect(reason: .closedByServer(closeCode: .invalid, reason: nil))
            return
        }

        await disconnect(reason: .failed(error: .transportFailed(description: error.localizedDescription)))
    }
}
