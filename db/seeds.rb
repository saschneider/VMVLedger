#
# Application seeds file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

# Set the service as disabled by default.
Service.create!(ui_enabled: false, jobs_enabled: false, retrieve_interval: 'P1D') if Service.count <= 0
Service.first.update(full_length_field: 'plainTextVote') if Service.first.full_length_field.blank?

# Add in initial users.
users = [
  { name: 'Admin User', email: 'info@pervasive-intelligence.co.uk' }
]

users.each do |user|
  Invitation.create!(email: user[:email], creator: user[:name]) if Invitation.find_by(email: user[:email]).nil?
  User.create!(email:            user[:email],
               password:         "#{user[:email].split('@').first}ChangeMe2019",
               forename:         user[:name].split(' ').first,
               surname:          user[:name].split(' ').last,
               role:             User.roles[:administrator],
               terms_of_service: true,
               confirmed_at:     Time.current) if User.find_by(email: user[:email]).nil?
end

# Add in the different file types.
file_type = FileType.find_or_create_by!(name: 'Election Parameters', action: :browse, public: true, content_type: 'text/csv', convert_to_content: true, needed_for_verify: true, sequence: 1)
file_type.update!(hint: 'public-election-params.csv')
file_type.update!(description: 'Contains the public cryptographic parameters for the election.')
file_type.update!(long_description: 'Contains the public cryptographic parameters which are used to generate the public election key and all voters\' keys. Further information about these parameters and keys, and how the keys are generated, can be found in the <a href="/documents" target="_blank">documentation</a>.')
file_type.update!(content_description: 'Shows the public cryptographic parameters which are used to generate the public election key and all voters\' keys. Further information about these parameters and keys, and how the keys are generated, can be found in the <a href="/documents" target="_blank">documentation</a>.')
file_type.update!(stage: :setup)

file_type = FileType.find_or_create_by!(name: 'Teller Information File', action: :no_action, public: false, content_type: 'text/xml', convert_to_content: false, needed_for_verify: false, sequence: 2)
file_type.update!(hint: 'teller-information-&lt;n&gt;.xml')
file_type.update!(description: 'Contains the Verificatum teller information for a specific teller.')
file_type.update!(stage: :setup)

file_type = FileType.find_or_create_by!(name: 'Election Keys', action: :no_action, public: false, content_type: 'text/csv', convert_to_content: true, needed_for_verify: false, sequence: 3)
file_type.update!(hint: 'election-keys.csv')
file_type.update!(description: 'Contains the election encryption keys.')
file_type.update!(stage: :setup)

file_type = FileType.find_or_create_by!(name: 'Election Public Key', action: :browse, public: true, content_type: 'text/csv', convert_to_content: true, needed_for_verify: false, sequence: 4)
file_type.update!(hint: 'public-election-keys.csv')
file_type.update!(description: 'Contains the public election encryption key used to encrypt all ballots in this election.')
file_type.update!(content_description: 'Shows the public election encryption key used to encrypt all votes and associated information.')
file_type.update!(stage: :setup)

file_type = FileType.find_or_create_by!(name: "Voters' Keys", action: :no_action, public: false, content_type: 'text/csv', convert_to_content: true, needed_for_verify: false, sequence: 5)
file_type.update!(hint: 'voters-keys.csv')
file_type.update!(description: 'Contains the private and public voter encryption and signing keys.')
file_type.update!(stage: :pre_election)

file_type = FileType.find_or_create_by!(name: "Voter Public Keys", action: :browse, public: true, content_type: 'text/csv', convert_to_content: true, needed_for_verify: false, sequence: 6)
file_type.update!(hint: 'public-voters-keys.csv')
file_type.update!(description: 'Contains the public voter encryption and signing keys.')
file_type.update!(long_description: 'Contains the public voter encryption and signing keys. Each voter is assigned two cryptographic keys. The first is used to sign each voter\'s ballot and the second is used to generate a commitment to the voter\'s tracker number.')
file_type.update!(content_description: 'Shows the public voter encryption and signing keys for a specific voter. Note that it is not possible to identify the voter.')
file_type.update!(stage: :pre_election)

file_type = FileType.find_or_create_by!(name: 'Tracker Numbers', action: :browse, public: true, content_type: 'text/csv', convert_to_content: true, needed_for_verify: true, sequence: 7)
file_type.update!(hint: 'public-tracker-numbers.csv')
file_type.update!(description: 'Contains the public plain text and encrypted tracker numbers used to allow a voter to verify their cast vote.')
file_type.update!(long_description: 'Contains the public plain text and encrypted tracker numbers used to allow a voter to verify their cast vote. Each voter is assigned a unique tracker number which is used to allow a voter to verify their cast vote. These tracker numbers are encrypted using election public key.')
file_type.update!(content_description: 'Shows the public plain text and encrypted tracker number used by a voter to verify their cast vote. Note that it is not possible to identify the voter.')
file_type.update!(stage: :setup)

file_type = FileType.find_or_create_by!(name: 'Shuffled and Encrypted Tracker Numbers', action: :browse, public: true, content_type: 'text/csv', convert_to_content: true, needed_for_verify: false, sequence: 8)
file_type.update!(hint: 'shuffled-tracker-numbers.csv')
file_type.update!(description: 'Contains the public encrypted tracker numbers in a random order such that it is not possible to know which plain text tracker number will be associated with which voter.')
file_type.update!(content_description: 'Shows the public encrypted tracker number associated with a voter. Note that it is not possible to identify the voter.')
file_type.update!(stage: :setup)

file_type = FileType.find_or_create_by!(name: 'Shuffled and Encrypted Tracker Numbers Proofs', action: :verificatum_proof_of_knowledge, public: true, content_type: 'application/zip', convert_to_content: false, needed_for_verify: false, sequence: 9)
file_type.update!(hint: 'shuffle-proofs-&lt;n&gt;.zip')
file_type.update!(description: 'Contains the Verificatum proof of shuffling of the public encrypted tracker numbers.')
file_type.update!(stage: :setup)

file_type = FileType.find_or_create_by!(name: 'Teller Commitments', action: :no_action, public: false, content_type: 'text/csv', convert_to_content: true, needed_for_verify: false, sequence: 10)
file_type.update!(hint: 'commitments-&lt;n&gt;.csv')
file_type.update!(description: 'Contains the private plain text commitment values for a specific teller. Commitment values are provided to a voter to allow them to obtain their tracker number.')
file_type.update!(stage: :pre_election)

file_type = FileType.find_or_create_by!(name: 'Teller Public Commitments', action: :browse, public: true, content_type: 'text/csv', convert_to_content: true, needed_for_verify: false, sequence: 11)
file_type.update!(hint: 'public-commitments-&lt;n&gt;.csv')
file_type.update!(description: 'Contains the public encrypted commitment values for a specific teller. Each election uses a number of independent tellers to ensure anonymity of the data.')
file_type.update!(content_description: 'Shows a public encrypted commitment value for a specific teller. Each election uses a number of independent tellers to ensure anonymity of the data. Commitment values are provided to a voter to allow them to obtain their tracker number.')
file_type.update!(stage: :pre_election)

file_type = FileType.find_or_create_by!(name: 'Teller Public Commitments Proofs', action: :vmv_proof_of_knowledge, public: true, content_type: 'text/csv', convert_to_content: true, needed_for_verify: false, sequence: 12)
file_type.update!(hint: 'commitments-proofs-&lt;n&gt;.csv')
file_type.update!(description: 'Contains the proof of knowledge of the commitment values for a specific teller. Each election uses a number of independent tellers to ensure anonymity of the data.')
file_type.update!(content_description: 'Shows the proof of knowledge of the commitment values for a specific commitment and teller. Each election uses a number of independent tellers to ensure anonymity of the data.')
file_type.update!(stage: :pre_election)

file_type = FileType.find_or_create_by!(name: 'Voter Public Keys with Encrypted Tracker Numbers', action: :browse, public: true, content_type: 'text/csv', convert_to_content: true, needed_for_verify: false, sequence: 13)
file_type.update!(hint: 'public-voters.csv')
file_type.update!(description: 'Contains the list of voter public keys, encrypted tracker number and partial commitment ready to be linked to a voter.')
file_type.update!(content_description: 'Shows the voter public keys, encrypted tracker number and partial commitment which will be linked to a randomly selected voter.')
file_type.update!(stage: :pre_election)
file_type.update!(needed_for_status: true)

file_type = FileType.find_or_create_by!(name: 'Voter Public Keys with Encrypted Tracker Numbers Proofs', action: :verificatum_proof_of_knowledge, public: true, content_type: 'application/zip', convert_to_content: false, needed_for_verify: false, sequence: 14)
file_type.update!(hint: 'decrypt-proofs-&lt;n&gt;.zip')
file_type.update!(description: 'Contains the Verificatum proof of decryption of the partial commitment for each commitment ready to be linked to a voter.')
file_type.update!(stage: :pre_election)

file_type = FileType.find_or_create_by!(name: 'Voter Public Keys with Encrypted Tracker Numbers (Associated)', action: :browse, public: false, content_type: 'text/csv', convert_to_content: true, needed_for_verify: false, sequence: 15)
file_type.update!(hint: 'public-associated-voters.csv')
file_type.update!(description: 'Contains the list of voter public keys, encrypted tracker number and partial commitment which have been linked to voters. No identifying information about voters is included.')
file_type.update!(content_description: 'Shows the voter public keys, encrypted tracker number and partial commitment which have been linked to a voter. Note that it is not possible to identify the voter.')
file_type.update!(stage: :pre_election)

file_type = FileType.find_or_create_by!(name: 'Encrypted Votes with Tracker Numbers', action: :browse, public: true, content_type: 'text/csv', convert_to_content: true, needed_for_verify: true, sequence: 16)
file_type.update!(hint: 'public-encrypted-voters.csv')
file_type.update!(description: 'Contains the encrypted and signed vote for each voter together with their voter public keys, encrypted tracker number and partial commitment.')
file_type.update!(content_description: 'Shows the encrypted and signed vote for a voter together with their voter public keys, encrypted tracker number and partial commitment. Note that it is not possible to identify the voter.')
file_type.update!(stage: :post_election)
file_type.update!(needed_for_status: true)

file_type = FileType.find_or_create_by!(name: 'Vote Choices', action: :browse, public: true, content_type: 'text/csv', convert_to_content: true, needed_for_verify: false, sequence: 17)
file_type.update!(hint: 'public-vote-options.csv')
file_type.update!(description: 'Contains the list of all possible choices that are available in the ballot.')
file_type.update!(content_description: 'Shows a possible choice available in the ballot.')
file_type.update!(stage: :setup)

file_type = FileType.find_or_create_by!(name: 'Encrypted Votes with Tracker Numbers Proofs', action: :vmv_proof_of_knowledge, public: true, content_type: 'text/csv', convert_to_content: true, needed_for_verify: false, sequence: 18)
file_type.update!(hint: 'encrypt-proofs.csv')
file_type.update!(description: 'Contains the proof of encryption of each encrypted vote for each voter. The values can be used with suitable cryptographic algorithms to verify that each vote was encrypted correctly.')
file_type.update!(content_description: 'Shows the proof of encryption of each encrypted vote for a voter. Note that it is not possible to identify the voter. The values can be used with suitable cryptographic algorithms to verify that each vote was encrypted correctly.')
file_type.update!(stage: :post_election)

file_type = FileType.find_or_create_by!(name: 'Final Votes', action: :browse, public: true, content_type: 'text/csv', convert_to_content: true, needed_for_verify: true, sequence: 19)
file_type.update!(hint: 'public-mixed-voters.csv')
file_type.update!(description: 'Contains the shuffled and decrypted list of all plain text votes cast and their associated tracker numbers. No identifying information about voters is included or was used during the shuffle and decryption.')
file_type.update!(long_description: 'Contains the shuffled and decrypted list of all plain text votes cast and their associated tracker numbers. No identifying information about voters is included or was used during the shuffle and decryption.<br><br>If you know your tracker number you can find it here and check your vote is included in the results.')
file_type.update!(content_description: 'Shows a plain text vote which has been cast by a voter and its associated plain text tracker number. Note that it is not possible to identify the voter.')
file_type.update!(stage: :post_election)

file_type = FileType.find_or_create_by!(name: 'Final Votes Proofs', action: :verificatum_proof_of_knowledge, public: true, content_type: 'application/zip', convert_to_content: false, needed_for_verify: false, sequence: 20)
file_type.update!(hint: 'mix-proofs-&lt;n&gt;.zip')
file_type.update!(description: 'Contains the Verificatum proof of shuffling and decryption of the encrypted votes and encrypted tracker numbers.')
file_type.update!(stage: :post_election)

unless Rails.env.development? || Rails.env.test?
  # Make sure we always have a single BlockchainRetrieveJob queued to run shortly after deployment.
  BlockchainRetrieveJob.set(wait: 5.minutes).perform_later unless BlockchainRetrieveJob.is_queued?
end