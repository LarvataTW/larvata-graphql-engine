module BaseTypes
  FileuploadType = GraphQL::ScalarType.define do
    name 'Fileupload'
    description 'action_dispatch_uploaded_file'
    coerce_input lambda { |file, _ctx|
      return nil if file.nil?

      ActionDispatch::Http::UploadedFile.new(
        filename: file.original_filename,
        type: file.content_type,
        head: file.headers,
        tempfile: file.tempfile
      )
    }
  end
end
