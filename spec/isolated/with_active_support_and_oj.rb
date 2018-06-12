require 'spec_helper'
require 'isolated/json_example'

describe 'with active_support and oj' do
  before do
    require 'active_support'
    require 'active_support/json'

    require 'oj'
    Oj.mimic_JSON
  end

  include_examples 'message_batch_json'
end
