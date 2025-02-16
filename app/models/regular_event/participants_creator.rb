# frozen_string_literal: true

class RegularEvent
  class ParticipantsCreator
    def self.call(regular_event:, target:, date_time: Time.current)
      return unless regular_event.all

      new(regular_event: regular_event, target: target, date_time: date_time).call
    end

    def initialize(regular_event:, target:, date_time:)
      @regular_event = regular_event
      @target = target
      @date_time = date_time.utc? ? date_time : date_time.utc
    end

    def call
      new_participants_ids = @target - @regular_event.participants.ids
      sql = <<~SQL
        INSERT INTO regular_event_participations (
          user_id,
          regular_event_id,
          created_at,
          updated_at
        )
        VALUES #{participants_values(new_participants_ids, @regular_event, @date_time)}
        ;
      SQL
      ActiveRecord::Base.connection.execute(sql) unless new_participants_ids.empty?
    end

    private

    def participants_values(participants_ids, regular_event, date_time)
      participants_ids.map { |id| "(#{id}, #{regular_event.id}, '#{date_time}', '#{date_time}')" }.join(',')
    end
  end
end
