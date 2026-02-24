-- 商品 id 7–12 的图片更新（Unsplash 风格，与示例一致：?w=400）
-- 风格示例：https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400
-- 7: USB-C 数据线  8: 手机支架  9: 桌面收纳盒  10: 护眼台灯  11: 静音小风扇  12: 移动硬盘 1TB

-- ------------------------------ 1）商品表 erp_list_product.company_product ------------------------------
USE `erp_list_product`;

UPDATE `company_product` SET `image_url` = 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg' WHERE `id` = 5;
UPDATE `company_product` SET `image_url` = 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg?__r__=1664285638581' WHERE `id` = 7;
UPDATE `company_product` SET `image_url` = 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg' WHERE `id` = 8;
UPDATE `company_product` SET `image_url` = 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg' WHERE `id` = 9;
UPDATE `company_product` SET `image_url` = 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg' WHERE `id` = 10;
UPDATE `company_product` SET `image_url` = 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg' WHERE `id` = 11;
UPDATE `company_product` SET `image_url` = 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg' WHERE `id` = 12;

-- ------------------------------ 2）订单明细表 erp_list_order.order_item（订单展示中的商品图） ------------------------------
USE `erp_list_order`;

UPDATE `order_item` SET `product_image` = 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg' WHERE `product_id` = 5;
UPDATE `order_item` SET `product_image` = 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg?__r__=1664285638581' WHERE `product_id` = 7;
UPDATE `order_item` SET `product_image` = 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg' WHERE `product_id` = 8;
UPDATE `order_item` SET `product_image` = 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg' WHERE `product_id` = 9;
UPDATE `order_item` SET `product_image` = 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg' WHERE `product_id` = 10;
UPDATE `order_item` SET `product_image` = 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg' WHERE `product_id` = 11;
UPDATE `order_item` SET `product_image` = 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg' WHERE `product_id` = 12;
