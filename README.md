# Assist eCommerce Ruby SDK

The Assist Ruby SDK provides Ruby APIs to create, process and manage payments via [Assist online payment service provider](http://www.assist.ru/).

## Features

* Creating payments
  * Instance payments
  * Delayed payments
  * Recurring payments
* Receiving status by order number
* Canceling payments

Read the documentation [[EN](http://www.assist.ru/files/TechNEW_ENG.pdf) | [RU](http://www.assist.ru/files/TechNew.pdf)] for more information about Assist's features.

## Requirements

- Ruby 1.9 or above
- Bundler

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'assist-ruby-sdk'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install assist-ruby-sdk

## Usage

Sample Rails application <https://github.com/chumakoff/assist-ruby-sample>

### Configuration

You have to configure Assist before using it.

```ruby
Assist.setup do |config|
  config.login = "login"
  config.password = "password"
  config.merchant_id = "111111"
  config.mode = :test # or :production
  # Provide secret word in order to activate check value (MD5) verification.
  # Make sure that the secret word is set in merchant's Personal account settings.
  config.secret_word = "secret_word"

  # Payment methods.
  # All payment methods are allowed by default. Specify this option only if you need to limit them.
  #
  # Default:
  # config.payment_methods = {card: true, ym: true, wm: true, qiwi: {mts: true, megafon: true, beeline: true, tele2: true}}
  #
  # Allow payments using credit card and QIWI(Megafon):
  # config.payment_methods = {card: true, wm: false, qiwi: {mts: false, megafon: true}}
  # Methods that are not present in the hash are considered as false.
  #
  # Allow payments using WebMoney and QIWI:
  # config.payment_methods = {wm: true, qiwi: true}
  config.payment_methods = {card: true}

  # The following options are not mandatory. If not specified,
  # merchant's settings in Personal account will be used (options should be enabled)
  config.success_url = "https://example.org/payment/success"
  config.fail_url = "https://example.org/payment/fail"
  # In the case when `success_url` and `fail_url` are the same, specify `return_url` instead.
  # config.return_url = "https://example.org/payment/return"
end
```

### Creating payments

In order to create a payment a user is redirected to the Assist payment page with necessary payment parameters:

```ruby
# `order_number` - order number in the merchant payment system
# `order_amount` - payment amount,  in original currency
# `extra_params` - hash of any other parameters (default = {}).
url = Assist.payment_url(order_number, order_amount, extra_params)
```
See "List of the authorized request parameters" in the documentation [[EN](http://www.assist.ru/files/TechNEW_ENG.pdf) | [RU](http://www.assist.ru/files/TechNew.pdf)].

### Checking payment status

```ruby
# `order_number` - order number in the merchant payment system
order_number = 999
order_status = Assist.order_status(order_number)

# with additional parameters
extra_params = {}
order_status = Assist.order_status(order_number, extra_params)

order_status.status     # => "Approved"
order_status.billnumber # => "5775486652369300"

# parameters sent in the HTTP request
order_status.request_params # => {merchant_id: '111111', login: 'login',
                            #     password: 'password', ...}

# response parameters
order_status.result # => [{:ordernumber=>"999", :billnumber=>"5775486652369300",
                    #      :orderamount=>"111.00", :ordercurrency=>"RUB",
                    #      :orderstate=>"Approved", :packetdate=>"28.09.2016 23:32",
                    #      :signature=>nil}]

# raw http response returned from Assist server (in XML format)
order_status.original_response # => #<Net::HTTPOK 200 OK readbody=true>
```

See "Receiving status by order number" and "OrderState field values" in the documentation for more information.

### Canceling payment

```ruby
# `billnumber` - number of payment in Assist
billnumber = "5775486652369300"
result = Assist.cancel_order(billnumber)

# with additional parameters
extra_params = {}
result = Assist.cancel_order(billnumber, extra_params)

# parameters sent in the HTTP request
result.request_params # => {merchant_id: '111111', login: 'login',
                      #     password: 'password', ...}

# response
result.result # => {:ordernumber=>"999", :responsecode=>"AS000",
              #     :recommendation=>nil, :orderdate=>"28.09.2016 23:31:00",
              #     :amount=>"111.00", :currency=>"RUB", :billnumber=>"5775486652369300",
              #     ...
              #    }

# raw http response returned from Assist server (in XML format)
order_status.original_response # => #<Net::HTTPOK 200 OK readbody=true>
```

## API Errors

When Assist API returns failure response, assist-ruby-sdk raises Assist::Exception::APIError containing error description and error codes.

```ruby
begin
  # Invalid API Request
rescue Assist::Exception::APIError => e
  e.message # => "Assist API error: firstcode=10, secondcode=201
end
```

See "Codes of automated interfaces" in the documentation for more information about error codes.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/chumakoff/assist-ecommerce-sdk-ruby.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).