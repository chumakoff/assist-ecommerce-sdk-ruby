shared_examples_for "correct params set" do
  it "should contain mandatory params" do
    mandatory_params.each do |key, value|
      expect(subject).to include string_or_hash(key => value)
    end
  end

  describe "default params" do
    it "should contain merchant id" do
      expect(subject).to include string_or_hash(merchant_id: required_config_options[:merchant_id])
    end

    describe "callbacks params" do
      context "when set in the config" do
        before(:each) do
          set_config do |config|
            config.success_url = "success"
            config.fail_url = "fail"
            config.return_url = "return"
          end
        end

        it "should contain correct callbacks params" do
          expect(subject).to include string_or_hash(url_return: "return")
          expect(subject).to include string_or_hash(url_return_ok: "success")
          expect(subject).to include string_or_hash(url_return_no: "fail")
        end
      end

      context "when not set" do
        it "should not contain any callbacks params" do
          expect(subject).to_not include string_or_hash("url_return")
          expect(subject).to_not include string_or_hash("url_return_ok")
          expect(subject).to_not include string_or_hash("url_return_no")
        end
      end
    end

    describe "payments methods params" do
      context "when set in the config" do
        context "when param is associated with TRUE" do
          before(:each) do
            set_config { |config| config.payment_methods = {card: true} }
          end

          it "should not contain the param" do
            expect(subject).to_not include string_or_hash("cardpayment")
          end
        end

        context "when param is associated with FALSE" do
          before(:each) do
            set_config { |config| config.payment_methods = {card: false} }
          end

          it "should contain param=0" do
            expect(subject).to include string_or_hash(cardpayment: 0)
          end
        end

        context "when param is not present" do
          before(:each) do
            set_config { |config| config.payment_methods = {wm: true, ym: true} }
          end

          it "should contain param=0" do
            expect(subject).to include string_or_hash(cardpayment: 0)
            expect(subject).to include string_or_hash(qiwipayment: 0)
          end
        end
      end

      context "when not set in the config" do
        it "should not contain any payment methods params" do
          payment_methods_params.each do |param_name|
            expect(subject).to_not include string_or_hash(param_name)
          end

          qiwi_params.each do |param_name|
            expect(subject).to_not include string_or_hash(param_name)
          end
        end
      end

      describe "QIWI payment methods params" do
        context "when TRUE" do
          before(:each) do
            set_config { |config| config.payment_methods = {qiwi: true} }
          end

          it "should not contain QIWIPayment param" do
            expect(subject).to_not include string_or_hash("qiwipayment")
          end

          it "should not contain nested QIWI params" do
            qiwi_params.each do |param_name|
              expect(subject).to_not include string_or_hash(param_name)
            end
          end
        end

        context "when FALSE" do
          before(:each) do
            set_config { |config| config.payment_methods = {qiwi: false} }
          end

          it "should contain 'QIWIPayment=0' param" do
            expect(subject).to include string_or_hash(qiwipayment: 0)
          end

          it "should not contain nested QIWI params" do
            qiwi_params.each do |param_name|
              expect(subject).to_not include string_or_hash(param_name)
            end
          end
        end

        context "when Hash" do
          context "when nested QIWI param is associated with TRUE" do
            before(:each) do
              set_config { |config| config.payment_methods = {qiwi: {mts: true}} }
            end

            it "should not contain 'QIWIPayment' param" do
              expect(subject).to_not include string_or_hash("qiwipayment")
            end

            it "should not contain the nested QIWI param" do
              expect(subject).to_not include string_or_hash("qiwimtspayment")
            end
          end

          context "when nested QIWI param is associated with FALSE" do
            before(:each) do
              set_config { |config| config.payment_methods = {qiwi: {megafon: false}} }
            end

            it "should not contain 'QIWIPayment' param" do
              expect(subject).to_not include string_or_hash("qiwipayment")
            end

            it "should contain nested_qiwi_param=0" do
              expect(subject).to include string_or_hash(qiwimtspayment: 0)
            end
          end

          context "when nested QIWI param is not present" do
            before(:each) do
              set_config { |config| config.payment_methods = {qiwi: {mts: true, megafon: true}} }
            end

            it "should not contain 'QIWIPayment' param" do
              expect(subject).to_not include string_or_hash("qiwipayment")
            end

            it "should contain nested_qiwi_param=0" do
              expect(subject).to include string_or_hash(qiwibeelinepayment: 0)
              expect(subject).to include string_or_hash(qiwitele2payment: 0)
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
        expect(subject).to include string_or_hash(checkvalue: "DBE8D1AB4F19A27D161999DC53293881")
      end
    end

    context "when secret word is not set in the config" do
      before(:each) { expect(Assist.config).to_not be_checkvalue }

      it "should not contain checkvalue" do
        expect(subject).to_not include string_or_hash("checkvalue")
      end
    end
  end

  describe "extra params" do
    let(:params) { mandatory_params.values << extra_params }

    context "when permitted" do
      it "should contain given extra params" do
        expect(subject).to include string_or_hash(language: "en")
      end

      it "should allow symbols as param names" do
        expect(subject).to include string_or_hash(ordercomment: "comment")
      end

      it "should downcase given extra params" do
        expect(subject).to include string_or_hash(homephone: "123")
      end

      it "should rewrite config params" do
        set_config { |config| config.return_url = 'return' }

        expect(subject).to_not include string_or_hash(url_return: "return")
        expect(subject).to include string_or_hash(url_return: "new_url_return")
      end
    end

    context "when not permitted" do
      it "should not contain extra params" do
        expect(subject).to_not include string_or_hash("missing")
      end
    end
  end
end