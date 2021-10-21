# frozen_string_literal: true

module JosieTalk
  # Error class from which all other errors are derived from.
  class Error < StandardError; end

  # UnknownKindError indicates that a given message kind was not associated
  # to a message type.
  class UnknownKindError < Error; end

  # UnknownCommandError indicates that a requested command was not registered
  # on the server.
  class UnknownCommandError < Error; end

  # UnauthorizedError indicates that the actor of an operation did not had
  # required permissions to execute it.
  class UnauthorizedError < Error; end

  # ClientNotRunningError indicates that a given callback has been cancelled
  # since its owner execution was stopped.
  class ClientNotRunningError < Error; end

  # UnexpectedResponseKindError indicates that a client responded to a request
  # with an unexpected message kind.
  class UnexpectedResponseKindError < Error; end

  # AbortError is used internally to notify upstream mechanisms that an event
  # loop must be stopped.
  class AbortError < Error; end
end
