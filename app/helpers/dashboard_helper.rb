module DashboardHelper
  def format_array_attribute(array)
    return "" if array.nil? || array.empty?
    array.join(", ")
  end

  def conflict_badge_class(conflict_count)
    "conflict-badge"
  end

  def format_date(date_string)
    return "" if date_string.nil?
    date_string
  end

  def conflict_type_label(type)
    case type
    when :concurrent_conflict
      "Concurrent Conflicts"
    when :successive_conflict
      "Successive Conflicts"
    when :lawyer_client_conflict
      "Lawyer-Client Conflicts"
    else
      type.to_s.humanize
    end
  end

  def format_conflicts_for_json(matter)
    return {} if matter.conflicts.nil? || matter.conflicts.empty?

    # Convert conflicts to JSON-friendly format
    json_conflicts = matter.conflicts.map do |conflict|
      {
        type: conflict[:type].to_s,
        former_matter: {
          matter_number: conflict[:former_matter].matter_number,
          title: conflict[:former_matter].title
        },
        reason: conflict[:reason]
      }
    end

    # Group conflicts by type
    json_conflicts.group_by { |conflict| conflict[:type] }
  end
end
