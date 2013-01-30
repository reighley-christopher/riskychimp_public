<?php
class Riskybiz_Chimp_Model_Observer
{
    /**
     * Event before show news item on frontend
     * If specified new post was added recently (term is defined in config) we'll see message about this on front-end.
     *
     * @param Varien_Event_Observer $observer
     */
    public function sendRequestToRiskybiz(Varien_Event_Observer $observer)
    {
        $order= $observer->getEvent()->getOrder();
        $quoteId =Mage::getSingleton('checkout/session')->getQuoteId();
        $data = Mage::helper('riskybiz_chimp')->getData($quoteId);
        $result = Mage::helper('riskybiz_chimp')->post('riskybiz.herokuapp.com', 80, '/api/transactions', $data);
        if ($result->score != NULL && $result->id != NULL)
        {
            Mage::helper('riskybiz_chimp')->saveScore($quoteId,$result->id,$result->score);
        }
    }
}
