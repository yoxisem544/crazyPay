require 'capybara'
require 'rest_client'
require 'iconv'
require 'nokogiri'
require 'pry'
require 'digest'

puts 'hi'

# postUrl = 'http://211.76.157.12/APIService/API/SpService.svc/MakeRPButton'
postUrl = 'https://ecapi.sinopac.com/WebAPI/Service.svc/QueryAllottedAccounts'
uri = "https://ecapi.sinopac.com/WebAPI/Service.svc/QueryAllottedAccounts"
postData = {
	'PFNO' => 'ZD0051',
	'KeyNum' => '3',
	'ResultType' => 'X',
	'PrdtName' => 'HelloWorld',
	'PrdtCurrency' => 'NTD',
	'PrdtPrice' => '12000',
	'PrdtQuantity' => '1',
	'PrdtMaxQuantity' => '1',
	'InvoiceService' => 'N',
	'BuyPageVer' => '1',
	'CustomParams' => '',
	'PayType' => 'A'
}

# r = RestClient.post postUrl, postData

@r = RestClient.get (uri){|response, request, result| @rs = result }

# binding.pry
puts @rs.header["www-authenticate"]
puts nonce = @rs.header["www-authenticate"].split(/["]/)[3] # get nonce

cnonce="5169746"

pfno = "ZD0051"
realm="DataWebService"
keyData1 = "38b4f4dc-04e4-4479-bd48-642bcad2913c"
keyData2 = "470c287d-5cc4-4280-855f-2a047835d888"
keyData3 = "27925e38-6539-4840-9db1-cdb9c722ffed"
httpMethod = "POST"
qop = "auth"

first = Digest::SHA256.hexdigest(pfno + ":" + realm + ":" + keyData1)
second = Digest::SHA256.hexdigest(httpMethod + ":" + uri)

verifycode = Digest::SHA256.hexdigest(first + ":" + nonce + ":" + cnonce + ":" + qop + ":" + "HelloWorld" + ":" + second)
rqData = "Digest realm=\"DataWebService\", nonce=\"#{nonce}\", uri=\"#{uri}\", verifycode=\"#{verifycode}\", qop=\"auth\", cnonce=\"#{cnonce}\""
# puts rqData

@r = RestClient::Request.execute(:method => :post, :url => uri, :headers => {"Authorization" => rqData}){|response, request, result| puts request.headers, result.code}
# @r = RestClient.post uri, {"Authorization" => rqData}
puts @r