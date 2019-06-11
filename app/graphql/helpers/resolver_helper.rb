module Helpers::ResolverHelper
  # 分頁參數宣告
  class ModelPagination < ::BaseTypes::BaseInputObject
    argument :page_number, Int, required: false, default_value: 1
    argument :page_size, Int, required: false, default_value: 10
  end

  # 處理傳入的查詢參數轉為 ransack 查詢
  def filters(args)
    if args.class != Hash
      args = args.arguments.argument_values.values
        .each_with_object({}){|arg, filters| filters[arg.definition.metadata[:type_class].keyword.to_s] = arg.value}
    end

    args
  end

  # 套用 ransack 查詢
  def apply_filter(scope, value)
    scope.ransack(filters(value)).result
  end

  # 處理傳入的分頁參數
  def apply_pagination(scope, value)
    scope.page(value[:page_number] || 1).per(value[:page_size] || 10)
  end

  # 建立可用的排序處理方法以及啟用 orderBy 排序條件設定
  def self.apply_order_by_methods(order_by_class)
    sorting_strs = order_by_class.values.keys

    sorting_strs.each do |sorting_str|
      Kernel.send(:define_method, "apply_orderBy_with_#{sorting_str.downcase}".to_sym) do |scope|
        sorting_str_array = sorting_str.split('_')
        sorting_column = sorting_str_array.keep_if{|w| ['ASC', 'DESC'].exclude? w}.join('_')
        sorting_dir = sorting_str_array.keep_if{|w| ['ASC', 'DESC'].include? w}.join

        scope.order("#{sorting_column} #{sorting_dir}")
      end
    end
  end
end
