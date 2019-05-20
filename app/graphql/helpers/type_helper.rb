module Helpers::TypeHelper
  # 處理找尋單筆資料的 batch 方法
  def belongs_to(obj, args, ctx, fk, associate_model, pk)
    model_class = associate_model.classify.constantize
    BatchLoader.for(obj.send(fk)).batch(cache: false, default_value: model_class.new) do |ids, loader|
      model_class.where(pk.to_sym => ids).each { |result| loader.call(result.send(pk), result) }
    end
  end

  # 處理找尋一筆或多筆資料的 batch 方法
  def has_one_or_many(obj, args, ctx, pk, associate_model, fk)
    model_class = associate_model.classify.constantize
    BatchLoader.for(obj.send(pk)).batch(cache: false, default_value: []) do |ids, loader|
      model_class.where(fk.to_sym => ids).page(args[:page_number]).per(args[:page_size]).each do |row_data|
        loader.call(row_data.send(fk)) { |result| result << row_data}
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
