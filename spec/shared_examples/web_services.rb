shared_examples_for "web service bad response" do |service_class|
  context "when successful response with error" do
    let(:result) { service_class.new("error", extra_params) }

    it "should raise an error with response error codes" do
      expect{ result.result }.to raise_error do |error|
        expect(error).to be_a Assist::Exception::APIError
        expect(error.message).to include("Assist API error")
        expect(error.message).to include("firstcode=10")
        expect(error.message).to include("secondcode=100")
      end
    end
  end

  context "when bad response" do
    let(:result) { service_class.new("bad", extra_params) }

    it "should raise an error with response code" do
      expect{ result.result }.to raise_error do |error|
        expect(error).to be_a Assist::Exception::APIError
        expect(error.message).to include("Invalid response")
        expect(error.message).to include("code=500")
      end
    end
  end
end

shared_examples_for "web service original response" do |service_class|
  context "when successful response" do
    subject { service_class.new("ok", extra_params).original_response }

    it "should return successfull http response" do
      expect(subject).to be_a Net::HTTPOK
      expect(subject.code.to_i).to eq 200
      expect(subject.body).to include "<ordernumber>100</ordernumber>"
    end
  end

  context "when successful response with error" do
    subject { service_class.new("error", extra_params).original_response }

    it "should return successfull http response with errors" do
      expect(subject).to be_a Net::HTTPOK
      expect(subject.code.to_i).to eq 200
      expect(subject.body).to include "firstcode='10' secondcode='100'"
    end
  end

  context "when bad response" do
    subject { service_class.new("bad", extra_params).original_response }

    it "should return bad http response" do
      expect(subject).to be_a Net::HTTPInternalServerError
      expect(subject.code.to_i).to eq 500
    end
  end
end

shared_examples_for "response with checkvalue" do
  context "when secret word is set in the config" do
    before(:each) do
      set_config { |config| config.secret_word = 'secret' }
      expect(Assist.config).to be_checkvalue
    end

    context "when correct checkvalue" do
      subject { Assist::WebServices::OrderStatus.new("ok", extra_params) }

      it "should not raise an error" do
        expect{ subject.result }.to_not raise_error
      end
    end

    context "when wrong checkvalue" do
      subject { Assist::WebServices::OrderStatus.new("wrong_checkvalue", extra_params) }

      it "should raise an error" do
        expect{ subject.result }.to raise_error(Assist::Exception::APIError,
                                                "Wrong checkvalue")
      end
    end
  end
end

shared_examples_for "correct params set" do
  it "should contain mandatory params" do
    expect(subject).to include mandatory_params
  end

  it "should contain default params" do
    expect(subject).to include({merchant_id: Assist.config.merchant_id,
                                login: Assist.config.login,
                                password: Assist.config.password,
                                format: 3})
  end

  it "should contain permitted extra params" do
    extra_params.keep_if { |k| k != :not_permitted }.each do |key, value|
      expect(subject).to include key.to_sym.downcase => value
    end
  end

  it "should not contain not permitted extra params" do
    expect(subject).to_not include not_permitted: extra_params[:not_permitted]
  end
end
