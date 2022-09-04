class BodController < ApplicationController
  def new
  end

  def details
    if session[:vnp_PayDate] == nil
      session[:vnp_PayDate] = Time.zone.now.strftime("%Y%m%d%H%M%S").to_time.strftime('%Y-%m-%d %H:%M:%S')
    end
  end

  def checkouts
    vnp_ResponseCode = params["vnp_ResponseCode"]
    if vnp_ResponseCode == "00"
      dataResponseCode = "Thanh toán thành công!"
      session[:vnp_Amount] = params['vnp_Amount'].to_i / 100
      session[:vnp_Name] = "LE NGOC HUY"
      session[:vnp_PayDate] = params['vnp_PayDate']
    elsif vnp_ResponseCode == "07" 
      dataResponseCode = "Trừ tiền thành công. Giao dịch bị nghi ngờ (liên quan tới lừa đảo, giao dịch bất thường)!"
    elsif vnp_ResponseCode == "09" 
      dataResponseCode = "Giao dịch không thành công do: Thẻ/Tài khoản của khách hàng chưa đăng ký dịch vụ InternetBanking tại ngân hàng!"
    elsif vnp_ResponseCode == "10" 
      dataResponseCode = "	Giao dịch không thành công do: Khách hàng xác thực thông tin thẻ/tài khoản không đúng quá 3 lần!"
    elsif vnp_ResponseCode == "11" 
      dataResponseCode = "Giao dịch không thành công do: Đã hết hạn chờ thanh toán. Xin quý khách vui lòng thực hiện lại giao dịch!"
    elsif vnp_ResponseCode == "12" 
      dataResponseCode = "Giao dịch không thành công do: Thẻ/Tài khoản của khách hàng bị khóa!"
    elsif vnp_ResponseCode == "13" 
      dataResponseCode = "Giao dịch không thành công do Quý khách nhập sai mật khẩu xác thực giao dịch (OTP). Xin quý khách vui lòng thực hiện lại giao dịch!"
    elsif vnp_ResponseCode == "24" 
      dataResponseCode = "Giao dịch không thành công do: Khách hàng hủy giao dịch!"
    elsif vnp_ResponseCode == "51" 
      dataResponseCode = "Giao dịch không thành công do: Tài khoản của quý khách không đủ số dư để thực hiện giao dịch!"
    elsif vnp_ResponseCode == "65" 
      dataResponseCode = "Giao dịch không thành công do: Tài khoản của Quý khách đã vượt quá hạn mức giao dịch trong ngày!"
    elsif vnp_ResponseCode == "75" 
      dataResponseCode = "Ngân hàng thanh toán đang bảo trì!"
    elsif vnp_ResponseCode == "79" 
      dataResponseCode = "Giao dịch không thành công do: KH nhập sai mật khẩu thanh toán quá số lần quy định. Xin quý khách vui lòng thực hiện lại giao dịch!"
    else
      dataResponseCode = "Các lỗi khác (lỗi còn lại, không có trong danh sách mã lỗi đã liệt kê)"
    end

    session[:vnp_TmnCode] = params[:vnp_TmnCode]
    session[:vnp_TxnRef] = params[:vnp_TxnRef]
    session[:vnp_OrderInfo] = params[:vnp_OrderInfo]
    session[:vnp_Amount] = (params[:vnp_Amount].to_i / 100).to_s
    session[:vnp_CardType] = params[:vnp_CardType]
    session[:vnp_ResponseCode] = params[:vnp_ResponseCode]
    session[:dataResponseCode] = dataResponseCode
    session[:vnp_PayDate] = params[:vnp_PayDate].to_time.strftime('%Y-%m-%d %H:%M:%S')
    session[:vnp_BankCode] = params[:vnp_BankCode]


  end

  def payment 
    redirect_to get_payment_url("https://pure-refuge-24132.herokuapp.com/checkouts"), allow_other_host: true
  end

  def fallback
    session[:strAmount] = params[:strAmount] 
  end


  private
      def get_payment_url(return_url)
        vnp_startTime =  Time.zone.now.strftime("%Y%m%d%H%M%S")
        vnp_ExpireDate =  Time.zone.now.strftime("%Y%m%d%H%M%S").to_i + 15.minutes
        session[:vnp_CreateDate] = vnp_startTime.to_time.strftime('%Y-%m-%d %H:%M:%S')
        # Mã website bên VNPAY cung cấp ban đầu cho mình
        vnp_tmncode = 'RV9WD0FH'
        # Chuỗi kí tự dùng cho việc mã hóa tham số do bên VNPAY cung cấp
        vnp_hash_secret = 'KFSJLMFKOIVOGGXRRNILHKZHDOMOCLIC'
        vnp_url = 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html'
        vnp_txnref = vnp_startTime
        vnp_order_info = "Thanh toan mua hang"
        vnp_order_type = "190000"
        vnp_amount = session[:strAmount].to_i * 100
        vnp_local = "vn"
        vnp_ipadd = request.remote_ip

        input_data = {
          "vnp_Amount" => vnp_amount,
          "vnp_Command" => "pay",
          "vnp_CreateDate" => vnp_startTime,
          "vnp_CurrCode" => "VND",
          "vnp_IpAddr" => vnp_ipadd,
          "vnp_Locale" => vnp_local,
          "vnp_OrderInfo" => vnp_order_info,
          "vnp_OrderType" => vnp_order_type,
          "vnp_ReturnUrl" => return_url,
          "vnp_TmnCode" => vnp_tmncode,
          "vnp_TxnRef" => vnp_txnref,
          "vnp_Version" => "2.0.0",
        }
        original_data = input_data.map do |key, value|
          "#{key}=#{value}"
        end.join("&")

        vnp_url = vnp_url + "?" + input_data.to_query
        vnp_security_hash = Digest::SHA256.hexdigest(vnp_hash_secret + original_data)
        vnp_url += '&vnp_SecureHashType=SHA256&vnp_SecureHash=' + vnp_security_hash
        vnp_url
      end

  private
      def checksum_valid!
        vnp_hash_secret = 'KFSJLMFKOIVOGGXRRNILHKZHDOMOCLIC'
        vnp_secure_hash = params["vnp_SecureHash"]
        data = response_params.to_h.map do |key, value|
          "#{key}=#{value}"
        end.join("&")
    
        secure_hash = Digest::SHA256.hexdigest(vnp_hash_secret + data)
        vnp_secure_hash == secure_hash
      end
    
      def response_params
        params.permit("vnp_Amount", "vnp_BankCode", "vnp_BankTranNo", "vnp_CardType", "vnp_OrderInfo", "vnp_PayDate", "vnp_ResponseCode", "vnp_TmnCode", "vnp_TransactionNo", "vnp_TxnRef")
      end
end
