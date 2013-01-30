<?php
class Riskybiz_Chimp_Helper_Data extends Mage_Core_Helper_Data
{
    /*
     * customer need to config the api key here
     */
    var $API_KEY = "2d37b86d2ea78c4b6d5f2caf49e96945d3f175c1";
    /*
     * 
     */
    public function saveScore($order_id,$trans_id,$result)
    {
        $score = Mage::getModel('chimp/score');
        $data = array('order_id' => $order_id, 'bucqua' => $trans_id, 'result' => $result);
        $score->setData($data);
        $score->save();
    }
    public function organizeString($string)
    {
        $start = stripos($string,"{");
        $end = strripos($string , "}") + 1;
        $length = $end - $start;
        return substr($string, $start, $length);
    }
            
    public function post($host, $port, $path, $data) {
        $http_response = '';
        $content_length = strlen($data);
        $fp = fsockopen($host,$port);
        fputs($fp, "POST $path HTTP/1.1\r\n");
        fputs($fp, "Host: $host\r\n");
        fputs($fp, "Content-Type: application/x-www-form-urlencoded\r\n");
        fputs($fp, "Content-Length: $content_length\r\n");
        fputs($fp, "Accept: application/json\r\n");
        fputs($fp, "Connection: close\r\n\r\n");
        fputs($fp, $data);
        while (!feof($fp)) $http_response .= fgets($fp, 28);
        fclose($fp);
        $http_response = $this->organizeString($http_response);
        $http_response = json_decode($http_response);
        return $http_response;
    }
    
    public function getData($orderId)
    {
        return $this->collectData($orderId);
    }
    
    protected function collectData($orderId)
    {
        $order = $this->getOrder($orderId);
        $email = $this->getEmail($order);
        $name = $this->getCustomerName($order);
        $ip = $this->getCustomerIp($order);
        $customer_id = $this->getCustomerID($order);
        $total = $this->getTotalAmount($order);
        $shipping_city = $this->getShippingCity($order);
        $shipping_country = $this->getShippingCountry($order);
        $shipping_postcode = $this->getShippingZip($order);
        $header = $this->getHeader();
        $user_agent = $_SERVER['HTTP_USER_AGENT'];
        
        return "api_key=".$this->API_KEY."&email=".$email."&name=".$name."&ip=".$ip."&purchaser_id=".$customer_id."&amount=".$total."&shipping_city=".$shipping_city.
                "&shipping_country=".$shipping_country."&shipping_zip=".$shipping_postcode."&user_agent=".$user_agent."&http_accept_header=".$header;
    }


    protected function getHeader()
    {
        $header = apache_request_headers();
        $result_header = "";
        foreach ($header as $details)
        {
            $result_header.="\n".$details;
        }
        return $result_header;
    }


    protected function getOrder($orderId)
    {
        return Mage::getModel('sales/order')->load($orderId);
    }
    
    protected function getEmail($order)
    {
        return $order->getData('customer_email');
    }
    
    protected function getCustomerName($order)
    {
        return $order->getData('customer_firstname')." ".$order->getData('customer_lastname');
    }
    
    protected function getCustomerIp($order)
    {
        return $order->getData('remote_ip');
    }
    
    protected function getCustomerID($order)
    {
        return $order->getData('customer_id');
    }
    
    protected function getTotalAmount($order)
    {
        return $order->getData('grand_total');
    }
    
    protected function getShippingAddress($order)
    {
        return Mage::getModel('sales/order_address')->load($order->getShippingAddressId());
    }

    protected function getShippingCity($order)
    {
        
        return $this->getShippingAddress($order)->getCity();
    }
    
    protected function getShippingCountry($order)
    {
      
        return  $this->getShippingAddress($order)->getCountryID();
    }
    
    protected function getShippingZip($order)
    {
        return $this->getShippingAddress($order)->getPostcode();
    }
}
