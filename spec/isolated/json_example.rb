RSpec.shared_examples 'message_batch_json' do
  it 'MessageBatch generates proper JSON' do
    batch = Segment::Analytics::MessageBatch.new(100)
    batch << Segment::Analytics::Message.new('a' => 'b')
    batch << Segment::Analytics::Message.new('c' => 'd')

    expect(JSON.generate(batch)).to eq('[{"a":"b"},{"c":"d"}]')
  end
end
