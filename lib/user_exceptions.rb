class UserException < Exception
	attr_reader :errors

	def initialize(errors={})
		super(description)
		@errors = errors
	end

	def description; end
	def status_code; end
	def u_code; end
	def build_view_object
		view_obj = {
			code: self.u_code,
			description: self.description,
			errors: {},
		}

		self.errors.each { |k,v| view_obj[:errors][k] = [v].flatten }
		view_obj
	end
end

class InputValidationError < UserException
	def description
		"Input Validation Error"
	end
	def status_code
		400
	end
	def u_code
		1005
	end
	def build_view_object
		view_obj = super
		view_obj
	end
end

class PermissionError < UserException
	def description
		"Requested operation not permitted"
	end
	def status_code
		403
	end
	def u_code
		1001
	end
	def build_view_object
		view_obj = super
		view_obj
	end
end

class UnAuthorizedAccessErorr < UserException
	def description
		"Not Authorized"
	end
	def status_code
		401
	end
	def u_code
		1007
	end
	def build_view_object
		view_obj = super
		view_obj
	end
end

class ResourceNotFoundError < UserException
	def description
		"Resource not found"
	end
	def status_code
		404
	end
	def u_code
		1002
	end
	def build_view_object
		view_obj = super
		view_obj
	end
end

class InvalidCredentialsError < UserException
	def description
		"User Name or Password did not match"
	end
	def status_code
		401
	end
	def u_code
		1003
	end
	def build_view_object
		view_obj = super
		view_obj
	end
end

class InvalidContentTypeError < UserException
	def description
		"Invalid content type"
	end
	def status_code
		415
	end
	def u_code
		1004
	end
	def build_view_object
		view_obj = super
		view_obj
	end
end

class NoUserCreateException < UserException
	def description
		"No user created"
	end
	def status_code
		400
	end
	def u_code
		1005
	end
	def build_view_object
		view_obj = super
		view_obj
	end
end

class NoConfirmationYetError < UserException
	def description
		"No confirmation done yet"
	end
	def status_code
		403
	end
	def u_code
		1006
	end
	def build_view_object
		view_obj = super
		view_obj
	end
end


