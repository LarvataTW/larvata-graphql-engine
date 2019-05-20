module BaseTypes
  DateTimeType = GraphQL::ScalarType.define do
    name 'DateTimeType'
    description "以 ISO 8601 格式顯示時間"

    coerce_input ->(value, _context) { Time.zone.parse value }
    coerce_result ->(value, _context) { value&.strftime('%FT%T') }
  end
end
