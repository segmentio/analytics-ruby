RSpec.shared_examples 'message_batch_json' do
  it 'MessageBatch generates proper JSON' do
    batch = SegmentIO::Analytics::MessageBatch.new(100)
    batch << { 'a' => 'b' }
    batch << { 'c' => 'd' }

    expect(JSON.generate(batch)).to eq('[{"a":"b"},{"c":"d"}]')
  end
end
