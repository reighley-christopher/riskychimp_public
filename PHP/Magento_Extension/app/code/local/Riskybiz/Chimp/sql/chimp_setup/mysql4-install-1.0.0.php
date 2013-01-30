<?php

$installer = $this;
$installer->startSetup();
$table = $installer->getConnection()->newTable($installer->getTable('chimp/score'))
        ->addColumn('score_id',  Varien_Db_Ddl_Table::TYPE_INTEGER, null, array(
            'unsigned' => true,
            'nullable' => false,
            'primary' => true,
            'identity' => true,
        ), 'Score ID')
        ->addColumn('order_id', Varien_Db_Ddl_Table::TYPE_INTEGER, null , array(
            'nullable' => false,
            'unsigned' => true,
        ), 'Order ID')
        ->addColumn('bucqua', Varien_Db_Ddl_Table::TYPE_INTEGER, null, array(
            'nullable' => false,
            'unsigned' => true,
        ),'Transaction ID')
        ->addColumn('result', Varien_Db_Ddl_Table::TYPE_FLOAT, null, array(
            'nullable' => false,
        ), 'Result')
        ->setComment('Riskybiz chimp/score entity table');
$installer->getConnection()->createTable($table);
$installer->endSetup();