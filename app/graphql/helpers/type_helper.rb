module Helpers::TypeHelper
  # 處理找尋單筆資料的 batch 方法
  def belongs_to(obj, args, ctx, associate_model, ids, loader)
    detail_class_name = obj.class.name.downcase.pluralize
    model_class = associate_model.classify.constantize

    association_sym = detail_class_name.to_sym
    scope = model_class.joins(association_sym)
    scope = scope.where(detail_class_name.pluralize.to_sym => {id: ids})

    scope.each { |result| loader.call(result.send(:id), result) }
  end

  # 處理找尋一筆或多筆資料的 batch 方法
  def has_one_or_many(obj, args, ctx, associate_model, ids, loader)
    master_class_name = obj.class.name.downcase
    model_class = associate_model.classify.constantize

    unless model_class.reflect_on_association(master_class_name.to_sym).nil?
      association_sym = master_class_name.to_sym
    else
      association_sym = master_class_name.pluralize.to_sym
    end

    scope = model_class.joins(association_sym)
    scope = scope.where(master_class_name.pluralize.to_sym => {id: ids})

    # 套用分頁參數
    unless args[:page_number].nil? and args[:page_size].nil?
      scope = scope.page(args[:page_number]).per(args[:page_size])
    end

    ids.each do |id|
      scope.uniq.each do |row_data|
        association = row_data.send(association_sym)
        loader.call(id) do |result| 
          if ( association.respond_to? :pluck and association.pluck(:id).include? id ) or 
              ( association.respond_to? :id and association&.id == id )
            result << row_data
          end
        end
      end
    end
  end

  # 依據 ActiveRecord mdoel 對應的表格欄位產生 field 定義
  def define_fields(model)
    model.columns.reject{|col| col.name.include? 'password'}.each do |col|
      name = col.name
      short_type = col.sql_type_metadata.sql_type[0..2]
      case short_type
      when 'big', 'int'
        if name == 'id'
          field :id, !types.ID, model.human_attribute_name(name)
        else
          field name.to_sym, types.Int, model.human_attribute_name(name)
        end
      when 'dec'
        field name.to_sym, types.Float, model.human_attribute_name(name)
      when 'dat'
        field name.to_sym, BaseTypes::DateTimeType, model.human_attribute_name(name)
      else # 'var', 'tex'
        field name.to_sym, types.String, model.human_attribute_name(name)
      end
    end
  end

  # 定義分頁輸入參數
  def define_pagination_arguments
    argument :page_number, types.Int, default_value: 1
    argument :page_size, types.Int, default_value: 10
  end

  # 定義分類輸入參數(Enum)
  def define_categories_enum(category_type)
    GraphQL::EnumType.define do 
      name "Categories"

      Category.send(category_type).each do |category|
        value category.sys_code, category.name, value: category.id
      end
    end    
  end
end
