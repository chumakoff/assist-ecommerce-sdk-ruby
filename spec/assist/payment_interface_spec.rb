require 'spec_helper'

def mandatory_params
  {ordernumber: 100, orderamount: 100.0}
end

def payment_methods_params
  %w(cardpayment ympayment wmpayment qiwipayment)
end

def qiwi_params
  %w(qiwimtspayment qiwimegafonpayment qiwibeelinepayment qiwitele2payment)
end

describe Assist::PaymentInterface do
  before(:each) { set_config }
  after(:each) { clear_config }

  describe "#url" do
    context "without extra parameters" do
      let(:url) { Assist::PaymentInterface.new(*mandatory_params.values).url }

      it "should contain mandatory parameters" do
        mandatory_params.each do |param_name, value|
          expect(url).to include "#{param_name}=#{value}"
        end
      end

      describe "default parameters" do
        it "should contain merchant id" do
          expect(url).to include "merchant_id=#{required_config_options[:merchant_id]}"
        end

        describe "callbacks parameters" do
          context "when set in the config" do
            before(:each) do
              set_config do |config|
                config.success_url = "success"
                config.fail_url = "fail"
                config.return_url = "return"
              end
            end

            it "should contain correct callbacks parameters" do
              expect(url).to include "url_return=return"
              expect(url).to include "url_return_ok=success"
              expect(url).to include "url_return_no=fail"
            end
          end

          context "when not set" do
            it "should not contain any callbacks parameters" do
              expect(url).to_not include "url_return"
              expect(url).to_not include "url_return_ok"
              expect(url).to_not include "url_return_no"
            end
          end
        end

        describe "payments methods parameters" do
          context "when set in the config" do
            context "when parameter is associated with TRUE" do
              before(:each) do
                set_config { |config| config.payment_methods = {card: true} }
              end

              it "should not contain the parameter" do
                expect(url).to_not include "cardpayment"
              end
            end

            context "when parameter is associated with FALSE" do
              before(:each) do
                set_config { |config| config.payment_methods = {card: false} }
              end

              it "should contain parameter=0" do
                expect(url).to include "cardpayment=0"
              end
            end

            context "when parameter is not present" do
              before(:each) do
                set_config { |config| config.payment_methods = {wm: true, ym: true} }
              end

              it "should contain parameter=0" do
                expect(url).to include "cardpayment=0"
                expect(url).to include "qiwipayment=0"
              end
            end
          end

          context "when not set in the config" do
            it "should not contain any payment methods parameters" do
              payment_methods_params.each do |param_name|
                expect(url).to_not include param_name
              end

              qiwi_params.each do |param_name|
                expect(url).to_not include param_name
              end
            end
          end

          describe "QIWI payment methods parameters" do
            context "when TRUE" do
              before(:each) do
                set_config { |config| config.payment_methods = {qiwi: true} }
              end

              it "should not contain QIWIPayment parameter" do
                expect(url).to_not include "qiwipayment"
              end

              it "should not contain nested QIWI parameters" do
                qiwi_params.each do |param_name|
                  expect(url).to_not include param_name
                end
              end
            end

            context "when FALSE" do
              before(:each) do
                set_config { |config| config.payment_methods = {qiwi: false} }
              end

              it "should contain 'QIWIPayment=0' parameter" do
                expect(url).to include "qiwipayment=0"
              end

              it "should not contain nested QIWI parameters" do
                qiwi_params.each do |param_name|
                  expect(url).to_not include param_name
                end
              end
            end

            context "when Hash" do
              context "when nested QIWI parameter is associated with TRUE" do
                before(:each) do
                  set_config { |config| config.payment_methods = {qiwi: {mts: true}} }
                end

                it "should not contain 'QIWIPayment' parameter" do
                  expect(url).to_not include "qiwipayment"
                end

                it "should not contain the nested QIWI parameter" do
                  expect(url).to_not include "qiwimtspayment"
                end
              end

              context "when nested QIWI parameter is associated with FALSE" do
                before(:each) do
                  set_config { |config| config.payment_methods = {qiwi: {megafon: false}} }
                end

                it "should not contain 'QIWIPayment' parameter" do
                  expect(url).to_not include "qiwipayment"
                end

                it "should contain nested_qiwi_parameter=0" do
                  expect(url).to include "qiwimtspayment=0"
                end
              end

              context "when nested QIWI parameter is not present" do
                before(:each) do
                  set_config { |config| config.payment_methods = {qiwi: {mts: true, megafon: true}} }
                end

                it "should not contain 'QIWIPayment' parameter" do
                  expect(url).to_not include "qiwipayment"
                end

                it "should contain nested_qiwi_parameter=0" do
                  expect(url).to include "qiwibeelinepayment=0"
                  expect(url).to include "qiwitele2payment=0"
                end
              end
            end
          end
        end
      end

      context "when secret word is set in the config" do
        before(:each) do
          set_config { |config| config.secret_word = 'secret' }
          expect(Assist.config).to be_checkvalue
        end

        it "should contain correct checkvalue" do
          expect(url).to include "checkvalue=DBE8D1AB4F19A27D161999DC53293881"
        end
      end

      context "when secret word is not set in the config" do
        before(:each) { expect(Assist.config).to_not be_checkvalue }

        it "should not contain checkvalue" do
          expect(url).to_not include "checkvalue"
        end
      end
    end

    context "with extra parameters" do
      let :url do
        parameters = mandatory_params.values
        parameters << {"language" => "en", :ordercomment => "comment", "HomePhone" => "123",
                       :missing => 'missing', "url_return" => 'new_url_return'}
        Assist::PaymentInterface.new(*parameters).url
      end

      context "when extra parameters are present in the permitted list" do
        it "should contain given extra parameters" do
          expect(url).to include "language=en"
        end

        it "should allow symbols as parameter names" do
          expect(url).to include "ordercomment=comment"
        end

        it "should downcase given extra parameters" do
          expect(url).to include "homephone=123"
        end

        it "should rewrite config parameters" do
          set_config { |config| config.return_url = 'return' }

          expect(Assist::PaymentInterface.new(*mandatory_params.values).url).to include "url_return=return"
          expect(url).to_not include "url_return=return"
          expect(url).to include "url_return=new_url_return"
        end
      end

      context "when extra parameters are not present in the permitted list" do
        it "should not contain extra parameters" do
          expect(url).to_not include "missing"
        end
      end
    end
  end
end
