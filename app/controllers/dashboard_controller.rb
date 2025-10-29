class DashboardController < ApplicationController
  def index
    @legal_matters = LegalMatter.all.sort_by { |matter| matter.opened_date }.reverse

    @legal_matters.each do |matter|
      next if matter.has_completed_conflict_check?

      # Get conflicts from all detectors (returns array of arrays)
      conflict_results = ConflictCollector.search(matter)

      # Flatten array of arrays and remove nils
      all_conflicts = conflict_results.flatten.compact

      # Store conflicts directly on the matter object
      matter.conflicts = all_conflicts
    end
  end
end
