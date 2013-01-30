<?php
Class Riskybiz_Chimp_Model_Resource_Score_Collection extends Mage_Core_Model_Resource_Db_Collection_Abstract
{
    protected function _construct() {
        $this->_init('chimp/score');
    }
}
