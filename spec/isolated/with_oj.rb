require 'spec_helper'
require 'isolated/json_example'

if RUBY_VERSION >= '2.0' && RUBY_PLATFORM != 'java'
  describe 'with oj' do
    before do
      require 'oj'
      Oj.mimic_JSON
    end

    include_examples 'message_batch_json'
  end
end
