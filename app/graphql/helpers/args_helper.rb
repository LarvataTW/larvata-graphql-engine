module Helpers::ArgsHelper
  # 將傳入的 args 轉變為 hash
  def args_to_attributes(args)
    args.argument_values.values.each_with_object({}){|arg, filters| 
      if arg.value&.is_a? Array
        filters["#{arg.key.to_s}_attributes"] = arg.value.map{|v| args_to_attributes(v)}
      elsif [String, Integer, Float].include? arg.value
        filters[arg.key.to_s] = arg.value
      end
    }
  end 
end

