<?php
class Riskybiz_Chimp_Model_Resource_Score extends Mage_Core_Model_Resource_Db_Abstract
{
    protected function _construct() {
        $this->_init('chimp/score', 'score_id');
    }
}
