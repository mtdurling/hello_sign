require 'integration/helper'

describe HelloSign do
  context "when sending a signature request" do
    context "when not using a reusable form" do
      let(:text_file_io)  { File.new('spec/fixtures/test.txt') }
      let(:image_io)      { File.new('spec/fixtures/test.jpg') }

      before do
        stub_post_with_auth('/signature_request/send')
        HelloSign.signature_request.deliver do |request|
          request.title   = 'Lease'
          request.subject = 'Sign this'
          request.message = 'You must sign this.'
          request.ccs     = ['lawyer@lawfirm.com', 'spouse@family.com']
          request.signers = [
            {:name => 'Jack', :email_address => 'jack@hill.com'},
            {:name => 'Jill', :email_address => 'jill@hill.com'}
          ]
          request.files   = [
            {:name => 'test.txt', :io => text_file_io, :mime => 'text/plain'},
            {:name => 'test.jpg', :io => image_io,     :mime => 'image/jpeg'}
          ]
        end
      end

      it "sends a signature request to the HelloSign API" do
        expect(a_post_with_auth('/signature_request/send')
          .with(:headers => {'Content-Type' => /multipart\/form-data/}, :body => /This is a test upload file\./)
        ).to have_been_made
      end
    end

    context "when using a reusable form" do
      before do
        stub_post_with_auth('/signature_request/send_with_reusable_form')
        HelloSign.signature_request.deliver(:form => 'form_id') do |request|
          request.title         = 'Lease'
          request.subject       = 'Sign this'
          request.message       = 'You must sign this.'
          request.ccs           = [
            {:email_address => 'lawyer@lawfirm.com', :role => 'lawyer'},
            {:email_address => 'accountant@llc.com', :role => 'accountant'}
          ]
          request.signers       = [
            {:name => 'Jack', :email_address => 'jack@hill.com', :role => 'consultant'},
            {:name => 'Jill', :email_address => 'jill@hill.com', :role => 'client'}
          ]
          request.custom_fields = [
            {:name => 'cost', :value => '$20,000'},
            {:name => 'time', :value => 'two weeks'}
          ]
        end
      end

      it "sends a signature request using a reusable form to the HelloSign API" do
        expect(a_post_with_auth('/signature_request/send_with_reusable_form')
          .with(:body => {
            :reusable_form_id => 'form_id',
            :title            => 'Lease',
            :subject          => 'Sign this',
            :message          => 'You must sign this.',
            :ccs              => {
              'lawyer'     => {:email_address => 'lawyer@lawfirm.com'},
              'accountant' => {:email_address => 'accountant@llc.com'}
            },
            :signers          => {
              'consultant' => {:name => 'Jack', :email_address => 'jack@hill.com'}, 
              'client'     => {:name => 'Jill', :email_address => 'jill@hill.com'}
            },
            :custom_fields    => {
              'cost' => '$20,000',
              'time' => 'two weeks'
            }
          })
        ).to have_been_made
      end
    end
  end

  context "when fetching a signature request" do
    before do
      stub_get_with_auth('/signature_request/request_id')
      HelloSign.signature_request.status('request_id')
    end

    it "fetches the signature request information from the HelloSign API" do
      expect(a_get_with_auth('/signature_request/request_id')).to have_been_made
    end
  end

  context "when getting a list of signature requests" do
    before do
      stub_get_with_auth('/signature_request/list?page=1')
      HelloSign.signature_request.list
    end

    it "fetches a list of signature requests from the HelloSign API" do
      expect(a_get_with_auth('/signature_request/list?page=1')).to have_been_made
    end
  end

  context "when sending a signature request reminder" do
    before do
      stub_post_with_auth('/signature_request/remind/request_id')
      HelloSign.signature_request.remind('request_id', :email => 'john@johnson.com')
    end

    it "sends a reminder request to the HelloSign API" do
      expect(a_post_with_auth('/signature_request/remind/request_id')
        .with(:body => {:email_address => 'john@johnson.com'})
      ).to have_been_made
    end
  end

  context "when canceling a signature request" do
    before do
      stub_post_with_auth('/signature_request/cancel/request_id')
      HelloSign.signature_request.cancel('request_id')
    end

    it "sends a signature request cancellation to the HelloSign API" do
      expect(a_post_with_auth('/signature_request/cancel/request_id')).to have_been_made
    end
  end

  context "when fetching a final copy of a signature request" do
    before do
      stub_get_with_auth('/signature_request/final_copy/request_id')
      HelloSign.signature_request.final_copy('request_id')
    end

    it "fetches a final copy of the signature request from the HelloSign API" do
      expect(a_get_with_auth('/signature_request/final_copy/request_id')).to have_been_made
    end
  end
end
