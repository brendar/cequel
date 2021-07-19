require "cassandra"
require "benchmark/ips"

module UUIDTester
  class << self
    def unsafe_uuid
      unsafe_uuid_generator.now
    end

    def threadsafe_uuid
      threadsafe_uuid_generator.now
    end

    def threadsafe_and_forksafe_uuid
      threadsafe_and_forksafe_uuid_generator.now
    end

    def new_every_time_uuid
      Cassandra::TimeUuid::Generator.new.now
    end

    private

    def unsafe_uuid_generator
      @unsafe_uuid_generator ||= Cassandra::TimeUuid::Generator.new
    end

    def threadsafe_uuid_generator
      Thread.current[:threadsafe_uuid_generator] ||= Cassandra::TimeUuid::Generator.new
    end

    def threadsafe_and_forksafe_uuid_generator
      current_pid = Process.pid
      if @pid != current_pid
        @pid = current_pid
        Thread.current[:threadsafe_and_forksafe_uuid_generator] = nil
      end
      Thread.current[:threadsafe_and_forksafe_uuid_generator] ||= Cassandra::TimeUuid::Generator.new
    end
  end
end

puts "#{RUBY_VERSION} #{RUBY_PLATFORM}"

Benchmark.ips do |x|
  x.report("unsafe_uuid") { UUIDTester.unsafe_uuid }
  x.report("threadsafe_uuid") { UUIDTester.threadsafe_uuid }
  x.report("threadsafe_and_forksafe_uuid") { UUIDTester.threadsafe_and_forksafe_uuid }
  x.report("new_every_time_uuid") { UUIDTester.new_every_time_uuid }
  x.compare!
end
