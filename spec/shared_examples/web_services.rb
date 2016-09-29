shared_examples_for "web service bad response" do |service_class|
  context "when successful response with error" do
    subject { service_class.new("error") }

    it "should raise an error with response error codes" do
      expect{ subject.result }.to raise_error do |error|
        expect(error).to be_a Assist::Exception::APIError
        expect(error.message).to include("Assist API error")
        expect(error.message).to include("firstcode=10")
        expect(error.message).to include("secondcode=100")
      end
    end
  end

  context "when bad response" do
    subject { service_class.new("bad") }

    it "should raise an error with response code" do
      expect{ subject.result }.to raise_error do |error|
        expect(error).to be_a Assist::Exception::APIError
        expect(error.message).to include("Invalid response")
        expect(error.message).to include("code=500")
      end
    end
  end
end

shared_examples_for "web service original response" do |service_class|
  context "when successful response" do
    subject { service_class.new("ok").original_response }

    it "should return successfull http response" do
      expect(subject).to be_a Net::HTTPOK
      expect(subject.code.to_i).to eq 200
      expect(subject.body).to include "<ordernumber>100</ordernumber>"
    end
  end

  context "when successful response with error" do
    subject { service_class.new("error").original_response }

    it "should return successfull http response with errors" do
      expect(subject).to be_a Net::HTTPOK
      expect(subject.code.to_i).to eq 200
      expect(subject.body).to include "firstcode='10' secondcode='100'"
    end
  end

  context "when bad response" do
    subject { service_class.new("bad").original_response }

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
      subject { Assist::WebServices::OrderStatus.new("ok") }

      it "should not raise an error" do
        expect{ subject.result }.to_not raise_error
      end
    end

    context "when wrong checkvalue" do
      subject { Assist::WebServices::OrderStatus.new("wrong_checkvalue") }

      it "should raise an error" do
        expect{ subject.result }.to raise_error(Assist::Exception::APIError,
                                                "Wrong checkvalue")
      end
    end
  end
end

shared_examples_for "api request with extra parameters" do |service_class|
  context "with extra parameters" do
    it "should be ok" do
      expect do
        service_class.new(
          "ok",
          "StartYear" => "2016",
          :StartMonth => "10",
          :startday => "29",
          "CancelReason" => 1,
          "Language" => "EN"
        )
      end
        .to_not raise_error
    end
  end
end
