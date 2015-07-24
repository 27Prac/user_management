def json_body_from_req
	raise InvalidContentTypeError, {content_type: "should be json"} unless valid_json_type?(request.content_type)
	req_body = request.body.read
	body = JSON.parse(req_body) rescue nil
	raise InputValidationError, {body: 'must be valid JSON'} if body.nil?
	body
end

def valid_json_type?(content_type)
	content_type && ( content_type.gsub(/;.*/, '') == 'application/json' )
end
