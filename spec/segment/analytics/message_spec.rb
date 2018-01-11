require 'spec_helper'

module Segment
  class Analytics
    describe Message do
      describe '#to_json' do
        it 'caches JSON conversions' do
          # Keeps track of the number of times to_json was called
          nested_obj = Class.new do
            attr_reader :to_json_call_count

            def initialize
              @to_json_call_count = 0
            end

            def to_json(*_)
              @to_json_call_count += 1
              '{}'
            end
          end.new

          message = Message.new('some_key' => nested_obj)
          expect(nested_obj.to_json_call_count).to eq(0)

          message.to_json
          expect(nested_obj.to_json_call_count).to eq(1)

          # When called a second time, the call count shouldn't increase
          message.to_json
          expect(nested_obj.to_json_call_count).to eq(1)
        end
      end
    end
  end
end
