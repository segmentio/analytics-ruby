require 'spec_helper'
require 'isolated/json_example'

describe 'with active_support' do
  before do
    require 'active_support'
    require 'active_support/json'
  end

  include_examples 'message_batch_json'
end
