class User < ApplicationRecord
    has_secure_password

	# Verify that email field is not blank and that it doesn't already exist in the db (prevents duplicates):
	validates :email, presence: true, uniqueness: true

	def generate_token
		# Replace this with your actual token generation logic
		# This is just a placeholder
		SecureRandom.hex(16)
	  end
end
