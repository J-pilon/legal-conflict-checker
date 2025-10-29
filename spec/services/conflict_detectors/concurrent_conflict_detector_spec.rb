require 'rails_helper'

RSpec.describe ConflictDetectors::ConcurrentConflictDetector, type: :service do
  let(:former_matter) { FactoryBot.build(:legal_matter, matter_number: "2024-001") }
  let(:prospective_matter) { FactoryBot.build(:legal_matter, matter_number: "2024-002", client_name: "Test Client") }

  describe '#detect' do
    context 'when matter numbers are the same' do
      it 'returns nil' do
        same_matter = FactoryBot.build(:legal_matter, matter_number: "2024-001")
        result = described_class.detect(same_matter, same_matter)

        expect(result).to be_nil
      end
    end

    context 'when related party matches prospective client name' do
      it 'returns a conflict hash' do
        former_with_matching_party = FactoryBot.build(:legal_matter,
          matter_number: "2024-001",
          related_parties: ["Test Client (Advisor)"]
        )
        prospective = FactoryBot.build(:legal_matter,
          matter_number: "2024-002",
          client_name: "Test client"
        )

        result = described_class.detect(former_with_matching_party, prospective)

        expect(result[:type]).to eq(:concurrent_conflict)
        expect(result[:former_matter]).to eq(former_with_matching_party)
        expect(result[:reason]).to eq("Related party matches client name")
      end

      it 'strips role descriptions before matching' do
        former_matter = FactoryBot.build(:legal_matter,
          matter_number: "2024-001",
          related_parties: ["Test Client (Attorney)", "Another Party (CEO)"]
        )
        prospective = FactoryBot.build(:legal_matter,
          matter_number: "2024-002",
          client_name: "Test Client"
        )

        result = described_class.detect(former_matter, prospective)

        expect(result).not_to be_nil
      end
    end

    context 'when no related party matches' do
      it 'returns nil' do
        former_no_match = FactoryBot.build(:legal_matter,
          matter_number: "2024-001",
          related_parties: ["Different Client (Advisor)"]
        )
        prospective = FactoryBot.build(:legal_matter,
          matter_number: "2024-002",
          client_name: "Test Client"
        )

        result = described_class.detect(former_no_match, prospective)

        expect(result).to be_nil
      end
    end

    context 'when related parties array is empty' do
      it 'returns nil' do
        former_empty = FactoryBot.build(:legal_matter,
          matter_number: "2024-001",
          related_parties: []
        )
        prospective = FactoryBot.build(:legal_matter,
          matter_number: "2024-002",
          client_name: "Test Client"
        )

        result = described_class.detect(former_empty, prospective)

        expect(result).to be_nil
      end
    end

    context 'case insensitivity' do
      it 'performs case insensitive matching' do
        former_matter = FactoryBot.build(:legal_matter,
          matter_number: "2024-001",
          related_parties: ["test client (Advisor)"]
        )
        prospective = FactoryBot.build(:legal_matter,
          matter_number: "2024-002",
          client_name: "Test Client"
        )

        result = described_class.detect(former_matter, prospective)

        expect(result).not_to be_nil
      end
    end
  end
end
