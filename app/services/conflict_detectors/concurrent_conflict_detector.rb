module ConflictDetectors
  class ConcurrentConflictDetector < ConflictDetector
    PARENTHESES_PATTERN = /\([A-Za-z0-9]+\)/

    def self.detect(former_matter, prospective_matter)
      instance = new(former_matter, prospective_matter)
      instance.detect
    end

    def detect
      return nil if former_matter.matter_number == prospective_matter.matter_number

      conflict_detected = former_matter.related_parties.any? do |related_party|
        related_party_name = related_party.gsub(PARENTHESES_PATTERN, "").strip

        related_party_name.downcase == prospective_matter.client_name.downcase
      end

      conflict_detected ? {
        type: :concurrent_conflict,
        former_matter: former_matter,
        reason: "Related party matches client name"
      } : nil
    end
  end
end
