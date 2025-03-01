# frozen_string_literal: true

module CircleCI
  module CLI
    module Printer
      class StepPrinter
        def initialize(steps, pretty: true)
          @steps = steps
          @pretty = pretty
        end

        def to_s # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          if @pretty
            Terminal::Table.new do |t|
              @steps
                .group_by(&:type)
                .each do |key, steps|
                t << :separator
                t << [{ value: key.green, alignment: :center, colspan: 2 }]
                steps.each { |s| print_actions(t, s) }
              end
            end.to_s
          else
            @steps.group_by(&:type).map do |_, steps|
              steps.map do |step|
                step.actions.map do |a|
                  "#{colorize_by_status(a.name.slice(0..120), a.status)}\n#{"#{a.log}\n" if a.failed? && a.log}"
                end
              end.flatten.join('')
            end.join("\n")
          end
        end

        private

        def colorize_by_status(string, status)
          case status
          when 'success', 'fixed' then string.green
          when 'canceled' then string.yellow
          when 'failed', 'timedout' then string.red
          when 'no_tests', 'not_run' then string.light_black
          else string
          end
        end

        def format_time(time)
          return '' unless time

          minute = format('%02d', time / 1000 / 60)
          second = format('%02d', (time / 1000) % 60)
          "#{minute}:#{second}"
        end

        def print_actions(table, step)
          table << :separator
          step.actions.each do |a|
            table << [
              colorize_by_status(a.name.slice(0..120), a.status),
              format_time(a.run_time_millis)
            ]
            table << [{ value: a.log, alignment: :left, colspan: 2 }] if a.failed? && a.log
          end
        end
      end
    end
  end
end
