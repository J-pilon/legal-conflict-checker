require 'rails_helper'

RSpec.describe ConflictDetectors::LawyerClientConflictDetector, type: :service do
  let(:attorney) { build(:attorney, name: "Test Attorney") }
  let(:former_matter) { build(:legal_matter, matter_number: "2024-001") }
  let(:prospective_matter) { build(:legal_matter, matter_number: "2024-002", assigned_attorney: "Test Attorney") }

  describe '#detect' do
    before do
      allow(Attorney).to receive(:find_by_name).and_return(attorney)
    end

    context 'when matter numbers are the same' do
      it 'returns nil' do
        same_matter = build(:legal_matter, matter_number: "2024-001")
        result = described_class.detect(same_matter, same_matter)

        expect(result).to be_nil
      end
    end

    context 'when attorney has business interest matching former client' do
      it 'returns a conflict hash' do
        attorney_with_interest = build(:attorney,
          name: "Test Attorney",
          business_interests: ["Former Client Corp"]
        )
        former_matter = build(:legal_matter,
          matter_number: "2024-001",
          client_name: "Former Client Corp"
        )
        prospective_matter = build(:legal_matter,
          matter_number: "2024-002",
          assigned_attorney: "Test Attorney"
        )

        allow(Attorney).to receive(:find_by_name).with("Test Attorney").and_return(attorney_with_interest)

        result = described_class.detect(former_matter, prospective_matter)

        expect(result[:type]).to eq(:lawyer_client_conflict)
        expect(result[:former_matter]).to eq(former_matter)
        expect(result[:reason]).to eq("Assigned attorney has business interest conflict")
      end

      it 'matches any business interest in the array' do
        attorney_with_multiple = build(:attorney,
          name: "Test Attorney",
          business_interests: ["Company A", "Former Client Corp", "Company B"]
        )
        former_matter = build(:legal_matter,
          matter_number: "2024-001",
          client_name: "Former Client Corp"
        )
        prospective_matter = build(:legal_matter,
          matter_number: "2024-002",
          assigned_attorney: "Test Attorney"
        )

        allow(Attorney).to receive(:find_by_name).with("Test Attorney").and_return(attorney_with_multiple)

        result = described_class.detect(former_matter, prospective_matter)

        expect(result).not_to be_nil
        expect(result[:type]).to eq(:lawyer_client_conflict)
      end
    end

    context 'when attorney has no matching business interest' do
      it 'returns nil' do
        attorney_no_match = build(:attorney,
          name: "Test Attorney",
          business_interests: ["Company A", "Company B"]
        )
        former_matter = build(:legal_matter,
          matter_number: "2024-001",
          client_name: "Different Client Corp"
        )
        prospective_matter = build(:legal_matter,
          matter_number: "2024-002",
          assigned_attorney: "Test Attorney"
        )

        allow(Attorney).to receive(:find_by_name).with("Test Attorney").and_return(attorney_no_match)

        result = described_class.detect(former_matter, prospective_matter)

        expect(result).to be_nil
      end
    end

    context 'when attorney has no business interests' do
      it 'returns nil' do
        attorney_empty = build(:attorney,
          name: "Test Attorney",
          business_interests: []
        )
        former_matter = build(:legal_matter,
          matter_number: "2024-001",
          client_name: "Any Client Corp"
        )
        prospective_matter = build(:legal_matter,
          matter_number: "2024-002",
          assigned_attorney: "Test Attorney"
        )

        allow(Attorney).to receive(:find_by_name).with("Test Attorney").and_return(attorney_empty)

        result = described_class.detect(former_matter, prospective_matter)

        expect(result).to be_nil
      end
    end

    context 'when attorney is not found' do
      it 'returns nil when assigned_attorney method returns nil' do
        former_matter = build(:legal_matter,
          matter_number: "2024-001",
          client_name: "Test Client"
        )
        prospective_matter = build(:legal_matter,
          matter_number: "2024-002",
          assigned_attorney: "Nonexistent Attorney"
        )

        allow(Attorney).to receive(:find_by_name).and_return(nil)

        result = described_class.detect(former_matter, prospective_matter)

        expect(result).to be_nil
      end
    end

    context 'case insensitivity' do
      it 'performs case insensitive matching' do
        attorney_with_interest = build(:attorney,
          name: "Test Attorney",
          business_interests: ["Client Corp"]
        )
        former_matter = build(:legal_matter,
          matter_number: "2024-001",
          client_name: "client corp"
        )
        prospective_matter = build(:legal_matter,
          matter_number: "2024-002",
          assigned_attorney: "Test Attorney"
        )

        allow(Attorney).to receive(:find_by_name).with("Test Attorney").and_return(attorney_with_interest)

        result = described_class.detect(former_matter, prospective_matter)

        expect(result).not_to be_nil
      end
    end
  end
end
