require 'rails_helper'

RSpec.describe Attorney, type: :model do
  describe '.all' do
    let(:mock_data) do
      {
        "attorneys" => [
          {
            "name" => "John Doe",
            "business_interests" => [ "Company A", "Company B" ]
          },
          {
            "name" => "Jane Smith",
            "business_interests" => [ "Company C" ]
          }
        ]
      }
    end

    before do
      allow(YAML).to receive(:load_file).and_return(mock_data)
      allow(Rails.root).to receive(:join).with("attorney_mocks.yml").and_return("attorney_mocks.yml")
    end

    it 'returns an array of Attorney objects' do
      attorneys = Attorney.all

      expect(attorneys).to be_an(Array)
      expect(attorneys.length).to eq(2)
      expect(attorneys.first).to be_an(Attorney)
    end

    it 'initializes Attorney objects with correct attributes' do
      attorneys = Attorney.all

      expect(attorneys.first.name).to eq("John Doe")
      expect(attorneys.first.business_interests).to eq([ "Company A", "Company B" ])
      expect(attorneys.last.name).to eq("Jane Smith")
      expect(attorneys.last.business_interests).to eq([ "Company C" ])
    end
  end

  describe '.find_by_name' do
    let(:mock_data) do
      {
        "attorneys" => [
          {
            "name" => "John Doe",
            "business_interests" => [ "Company A" ]
          },
          {
            "name" => "Jane Smith",
            "business_interests" => [ "Company B" ]
          }
        ]
      }
    end

    before do
      allow(YAML).to receive(:load_file).and_return(mock_data)
      allow(Rails.root).to receive(:join).with("attorney_mocks.yml").and_return("attorney_mocks.yml")
    end

    it 'finds an attorney by name' do
      attorney = Attorney.find_by_name("John Doe")

      expect(attorney).to be_an(Attorney)
      expect(attorney.name).to eq("John Doe")
    end

    it 'returns nil when attorney is not found' do
      attorney = Attorney.find_by_name("Nonexistent Attorney")

      expect(attorney).to be_nil
    end
  end

  describe '#initialize' do
    let(:attorney_data) do
      {
        "name" => "Test Attorney",
        "business_interests" => [ "Company A", "Company B", "Company C" ]
      }
    end

    it 'initializes an Attorney with correct attributes' do
      attorney = Attorney.new(attorney_data)

      expect(attorney.name).to eq("Test Attorney")
      expect(attorney.business_interests).to eq([ "Company A", "Company B", "Company C" ])
    end
  end

  describe 'with FactoryBot' do
    it 'creates a valid attorney' do
      attorney = build(:attorney)

      expect(attorney.name).to be_present
      expect(attorney.business_interests).to be_an(Array)
      expect(attorney.business_interests.length).to be >= 1
    end

    it 'creates an attorney with specific business interest' do
      attorney = build(:attorney, :with_specific_business_interest)

      expect(attorney.business_interests).to eq([ "Test Company Inc" ])
    end

    it 'creates an attorney with multiple interests' do
      attorney = build(:attorney, :with_multiple_interests)

      expect(attorney.business_interests.length).to eq(3)
      expect(attorney.business_interests).to include("Company A", "Company B", "Company C")
    end
  end
end
