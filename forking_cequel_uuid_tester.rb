require "set"
require "cequel"
require "parallel"

class ForkingCequelUuidTester
  def self.run(num_processes:, num_uuids:)
    Cequel.uuid # Initialize the memoized Cassandra::TimeUuid::Generator

    results = Parallel.map(Array.new(num_processes), in_processes: num_processes) do
      uuids = []
      num_uuids.times do
        uuids << Cequel.uuid
      end
      uuids
    end

    count = 0
    duplicate_count = 0
    results.flatten.each_with_object(Set.new) do |uuid, set|
      count += 1
      unless set.add?(uuid)
        duplicate_count += 1
      end
    end

    puts "Generated #{count} uuids with #{duplicate_count} duplicates"
  end
end

ForkingCequelUuidTester.run(num_processes: 8, num_uuids: 1_000)
