require 'spec_helper'
require 'shared_examples/payment_interface'

def string_or_hash(value)
  return value unless subject.is_a?(String)

  case value
  when String, Numeric
    value.to_s
  when Hash
    raise "Should have one element" if value.size != 1
    "#{value.keys[0]}=#{value.values[0]}"
  else
    raise "Wrong value"
  end
end

describe Assist::PaymentInterface do
  before(:each) { set_config }
  after(:each) { clear_config }

  let(:mandatory_params) { {ordernumber: 100, orderamount: 100.0} }
  let(:payment_methods_params) { %w(cardpayment ympayment wmpayment qiwipayment) }
  let(:qiwi_params) { %w(qiwimtspayment qiwimegafonpayment qiwibeelinepayment qiwitele2payment) }
  let(:params) { mandatory_params.values }

  let(:extra_params) do
    {
      "language" => "en", :ordercomment => "comment", "HomePhone" => "123",
      :missing => 'missing', "url_return" => 'new_url_return'
    }
  end

  describe "#url" do
    subject { Assist::PaymentInterface.new(*params).url }

    it "should return a String" do
      expect(subject).to be_a String
    end

    it_behaves_like "correct params set"
  end

  describe "#params" do
    subject { Assist::PaymentInterface.new(*params).send(:params) }

    it "should return a Hash" do
      expect(subject).to be_a Hash
    end

    it_behaves_like "correct params set"
  end
end
