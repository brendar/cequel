require "set"
require "cequel"
require "timecop"

class ThreadedCequelUuidTester
  def self.run(num_threads:, num_uuids:)
    Cequel.uuid # Initialize the memoized Cassandra::TimeUuid::Generator

    # Makes duplicates more likely as it only requires a race condition on incrementing the sequence number,
    # rather than both clock value and sequence number. I found this necessary to observe duplicates when using MRI,
    # but it was not necessary with JRuby
    Timecop.freeze

    threads = num_threads.times.map do
      Thread.new do
        uuids = []
        num_uuids.times do
          uuids << Cequel.uuid
        end
        uuids
      end
    end

    count = 0
    duplicate_count = 0
    threads.map(&:value).flatten.each_with_object(Set.new) do |uuid, set|
      count += 1
      unless set.add?(uuid)
        duplicate_count += 1
      end
    end

    puts "Generated #{count} uuids with #{duplicate_count} duplicates"
  end
end

ThreadedCequelUuidTester.run(num_threads: 8, num_uuids: 1_000_000)
