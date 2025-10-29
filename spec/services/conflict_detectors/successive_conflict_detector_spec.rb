require 'rails_helper'

RSpec.describe ConflictDetectors::SuccessiveConflictDetector, type: :service do
  let(:former_matter) { build(:legal_matter, matter_number: "2024-001") }
  let(:prospective_matter) { build(:legal_matter, matter_number: "2024-002") }

  describe '#detect' do
    context 'when matter numbers are the same' do
      it 'returns false' do
        same_matter = build(:legal_matter, matter_number: "2024-001")
        result = described_class.detect(same_matter, same_matter)

        expect(result).to be false
      end
    end

    context 'when description similarity is above threshold' do
      it 'returns a conflict hash' do
        former_matter = build(:legal_matter,
          matter_number: "2024-001",
          description: "Employment discrimination claim involving workplace harassment and wrongful termination allegations"
        )
        prospective_matter = build(:legal_matter,
          matter_number: "2024-002",
          description: "Employment discrimination workplace harassment termination wrongful allegations claim"
        )

        result = described_class.detect(former_matter, prospective_matter)

        expect(result[:type]).to eq(:successive_conflict)
        expect(result[:former_matter]).to eq(former_matter)
        expect(result[:reason]).to eq("Former client in the same or a related matter")
      end

      it 'calculates percentage correctly' do
        former_matter = build(:legal_matter,
          matter_number: "2024-001",
          description: "test keyword one two three four five"
        )
        prospective_matter = build(:legal_matter,
          matter_number: "2024-002",
          description: "test keyword one two three"
        )
        # 4 out of 5 words match = 80% > 40% threshold

        result = described_class.detect(former_matter, prospective_matter)

        expect(result).not_to be_nil
        expect(result[:type]).to eq(:successive_conflict)
      end
    end

    context 'when description similarity is below threshold' do
      it 'returns nil' do
        former_matter = build(:legal_matter,
          matter_number: "2024-001",
          description: "one two three four five six seven eight nine ten"
        )
        prospective_matter = build(:legal_matter,
          matter_number: "2024-002",
          description: "one two three"
        )
        # 3 out of 10 words match = 30% < 40% threshold

        result = described_class.detect(former_matter, prospective_matter)

        expect(result).to be_nil
      end
    end

    context 'when no keywords match' do
      it 'returns nil' do
        former_matter = build(:legal_matter,
          matter_number: "2024-001",
          description: "completely different description"
        )
        prospective_matter = build(:legal_matter,
          matter_number: "2024-002",
          description: "totally unrelated matter"
        )

        result = described_class.detect(former_matter, prospective_matter)

        expect(result).to be_nil
      end
    end

    context 'when descriptions are identical' do
      it 'returns a conflict hash' do
        description = "Employment discrimination claim"
        former_matter = build(:legal_matter,
          matter_number: "2024-001",
          description: description
        )
        prospective_matter = build(:legal_matter,
          matter_number: "2024-002",
          description: description
        )

        result = described_class.detect(former_matter, prospective_matter)

        expect(result).not_to be_nil
        expect(result[:type]).to eq(:successive_conflict)
      end
    end

    context 'when former matter description is empty' do
      it 'handles gracefully' do
        former_matter = build(:legal_matter,
          matter_number: "2024-001",
          description: ""
        )
        prospective_matter = build(:legal_matter,
          matter_number: "2024-002",
          description: "some description"
        )

        result = described_class.detect(former_matter, prospective_matter)

        expect(result).to be_nil
      end
    end

    context 'word matching' do
      it 'matches partial words within full words' do
        former_matter = build(:legal_matter,
          matter_number: "2024-001",
          description: "employment discrimination"
        )
        prospective_matter = build(:legal_matter,
          matter_number: "2024-002",
          description: "employment discrimination workplace"
        )

        result = described_class.detect(former_matter, prospective_matter)

        expect(result).not_to be_nil
      end

      it 'performs case insensitive matching' do
        former_matter = build(:legal_matter,
          matter_number: "2024-001",
          description: "Employment Discrimination"
        )
        prospective_matter = build(:legal_matter,
          matter_number: "2024-002",
          description: "employment Test"
        )

        result = described_class.detect(former_matter, prospective_matter)

        expect(result).not_to be_nil
      end
    end

    context 'edge cases' do
      it 'handles very long descriptions' do
        long_description = "word " * 100
        former_matter = build(:legal_matter,
          matter_number: "2024-001",
          description: long_description
        )
        prospective_matter = build(:legal_matter,
          matter_number: "2024-002",
          description: "word " * 50 + "other " * 50
        )
        # 50% match, should trigger conflict

        result = described_class.detect(former_matter, prospective_matter)

        expect(result).not_to be_nil
      end
    end
  end
end
