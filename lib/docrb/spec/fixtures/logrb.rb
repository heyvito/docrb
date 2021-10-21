# frozen_string_literal: true

require_relative "logrb/version"
require "hexdump"
require "json"

# Logrb provides a facility for working with logs in text and json formats.
# All instances share a single mutex to ensure logging consistency.
# The following attributes are available:
#
# fields - A hash containing metadata to be included in logs emitted by this
#          instance.
# level  - The level filter for the instance. Valid values are :error, :fatal,
#          :info, :warn, and :debug
# format - The format to output logs. Supports :text and :json.
#
# Each instance exposes the following methods, which accepts an arbitrary
# number of key-value pairs to be included in the logged message:
#
# #error(msg, error=nil, **fields): Outputs an error entry. When `error` is
#   present, attempts to obtain backtrace information and also includes it
#   to the emitted entry.
#
# #fatal(msg, **fields): Outputs a fatal entry. Calling fatal causes the
#   current process to exit with a status 1.
#
# #warn(msg, **fields): Outputs a warning entry.
# #info(msg, **fields): Outputs a informational entry.
# #debug(msg, **fields): Outputs a debug entry.
# #dump(msg, data=nil): Outputs a given String or Array of bytes using the
#   same format as `hexdump -C`.
class Logrb
  attr_accessor :fields, :level, :format

  COLORS = {
    error: 31,
    fatal: 31,
    unknown: 0,
    info: 36,
    warn: 33,
    debug: 30,
    reset: 0,
    dump: 37
  }.freeze

  BACKGROUNDS = {
    debug: 107
  }.freeze

  LEVELS = {
    error: 4,
    fatal: 4,
    unknown: 4,
    warn: 3,
    info: 2,
    debug: 1,
    reset: 1
  }.freeze

  # Internal: A mutex instance used for synchronizing the usage of the output
  # IO.
  def self.mutex
    @mutex ||= Mutex.new
  end

  # Initializes a new Logger instance that outputs logs to a provided output.
  #
  # output - an IO-like object that implements a #write method.
  # format - Optional. Indicates the format used to output log entries.
  #          Supports :text (default) and :json.
  # level  - Level to filter this logger instance
  # fields - Fields to include in emitted entries
  def initialize(output, format: :text, level: :debug, **fields)
    @output = output
    @format = format
    @fields = fields
    @level = level
  end

  # Returns a new logger instance using the same output of its parent's, with
  # an optional set of fields to be merged against the parent's fields.
  #
  # fields - A Hash containing metadata to be included in all output entries
  #          emitted from the returned instance.
  def with_fields(**fields)
    inst = Logrb.new(@output, format: @format, level: @level)
    inst.fields = @fields.merge(fields)
    inst
  end

  LEVELS.except(:error, :fatal).each_key do |name|
    define_method(name) do |msg, **fields|
      return if LEVELS[@level] > LEVELS[name]

      wrap(name, msg, nil, fields)
      nil
    end
  end

  # Public: Emits an error to the log output. When error is provided, this
  # method attempts to gather a stacktrace to include in the emitted entry.
  def error(msg, error = nil, **fields)
    return if LEVELS[@level] > LEVELS[:error]

    wrap(:error, msg, error, fields)
    nil
  end

  # Public: Emits a fatal message to the log output, and invokes Kernel#exit
  # with a non-zero status code. When error is provided, this method attempts
  # to gather a stacktrace to include in the emitted entry. This log entry
  # cannot be filtered, and is always emitted.
  def fatal(msg, error = nil, **fields)
    wrap(:fatal, msg, error, fields)
    exit 1
  end

  # Public: Dumps a given String or Array in the same format as `hexdump -C`.
  def dump(log, data = nil, **fields)
    return if LEVELS[@level] > LEVELS[:debug]

    if data.nil?
      data = log
      log = nil
    end

    data = data.pack("C*") if data.is_a? Array
    dump = []
    padding = @format == :json ? "" : "        "
    Hexdump.dump(data, output: dump)
    dump.map! { |line| "#{padding}#{line.chomp}" }
    dump = dump.join("\n")

    if @format == :json
      fields[:dump] = dump
      dump = nil
    end
    wrap(:dump, log || "", nil, fields)
    write_output("#{dump}\n\n") unless dump.nil?
  end

  private

  # Internal: Formats a given text using the ANSI escape sequences. Notice
  # that this method does not attempt to determine whether the current output
  # supports escape sequences.
  def color(color, text)
    bg = BACKGROUNDS[color]
    reset_bg = ""
    if bg
      bg = "\e[#{bg}m"
      reset_bg = "\e[49m"
    end
    "#{bg}\e[#{COLORS[color]}m#{text}\e[#{COLORS[:reset]}m#{reset_bg}"
  end

  # Internal: Removes all backtrace frames pointing to the logging facility
  # itself.
  def clean_caller_locations
    caller_locations.reject { |t| t.absolute_path&.end_with?("logrb.rb") }
  end

  # Internal: Returns the caller of a function, returning a pair containing
  # its path and base method name.
  def determine_caller
    c = clean_caller_locations.first
    [normalize_location(c), c.base_label]
  end

  # Internal: Performs a cleanup for a given backtrace frame.
  #
  # trace - Trace to be clean.
  # include_function_name - Optional. When true, includes the function name
  #   on the normalized string. Defaults to false.
  def normalize_location(trace, include_function_name: false)
    path = trace.absolute_path
    return trace.to_s if path.nil?

    if (root = Gem.path.find { |p| path.start_with?(p) })
      path = "$GEM_PATH#{path[root.length..]}"
    end
    "#{path}:#{trace.lineno}#{include_function_name ? " in `#{trace.label}'" : ""}"
  end

  # Internal: Returns a string containing a stacktrace of the current
  # invocation.
  def stack_trace(trace = clean_caller_locations)
    trace.map { |s| normalize_location(s, include_function_name: true) }.join("\n")
  end

  # Internal: Composes a log line with given information.
  #
  # level       - The severity of the log message
  # caller_meta - An Array containing the caller's location and name
  # msg         - The message to be logged
  # fields      - A Hash of fields to be included in the entry
  def compose_line(level, caller_meta, msg, fields)
    ts = Time.now.strftime("%Y-%m-%dT%H:%M:%S.%L%z")
    msg = " #{msg}" unless msg.empty?
    fields_str = if fields.empty?
                   ""
                 else
                   " #{fields}"
                 end
    level_str = color(level, level.to_s.upcase)
    "#{ts} #{level_str}: #{caller_meta.last}:#{msg}#{fields_str}"
  end

  # Internal: Logs a text entry to the current output.
  #
  # level       - The severity of the message to be logged.
  # msg         - The message to be logged
  # error       - Either an Exception object or nil. This parameter is used
  #               to provide extra information on the logged entry.
  # fields      - A Hash containing metadata to be included in the logged
  #               entry.
  # caller_meta - An Array containing the caller's location and name.
  def text(level, msg, error, fields, caller_meta)
    fields ||= {}
    fields.merge! @fields
    write_output(compose_line(level, caller_meta, msg, fields))
    if (error_message = error&.message)
      write_output(": #{error_message}")
    end
    write_output("\n")
    return unless level == :error

    backtrace_str = backtrace(error)
                    .split("\n")
                    .map { |s| "        #{s}" }.join("\n")
    write_output(backtrace_str)
    write_output("\n")
  end

  # Internal: Attempts to obtain a backtrace from a provided object. In case
  # the object does not include backtrace metadata, uses #stack_trace as a
  # fallback.
  def backtrace(from)
    if from.respond_to?(:backtrace_locations) && !from.backtrace_locations.nil?
      stack_trace(from.backtrace_locations)
    else
      stack_trace
    end
  end

  # Internal: Writes a given value to the current's output IO. Calls to this
  # method are thread-safe.
  def write_output(text)
    Logrb.mutex.synchronize do
      @output.write(text)
    end
  end

  # Internal: Logs a JSON entry to the current output.
  #
  # level       - The severity of the message to be logged.
  # msg         - The message to be logged
  # error       - Either an Exception object or nil. This parameter is used
  #               to provide extra information on the logged entry.
  # fields      - A Hash containing metadata to be included in the logged
  #               entry.
  # caller_meta - An Array containing the caller's location and name.
  def json(level, msg, error, fields, caller_meta)
    fields ||= {}
    fields.merge! @fields
    data = {
      level: level,
      caller: caller_meta.first,
      msg: msg,
      ts: Time.now.utc.to_i
    }

    data[:stacktrace] = backtrace(error) if level == :error

    data.merge!(fields)
    write_output("#{data.to_json}\n")
  end

  # Internal: Dynamically invokes the current log formatter for the
  # provided arguments. For further information, see #text and #json
  def wrap(level, msg, error, fields)
    msg = msg.to_s
    send(@format, level, msg, error, fields, determine_caller)
    exit 1 if level == :fatal
  end
end
