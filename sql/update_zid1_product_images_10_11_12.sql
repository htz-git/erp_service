-- 商品 id 7–12 的图片更新（Unsplash 风格，与示例一致：?w=400）
-- 风格示例：https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400
-- 7: USB-C 数据线  8: 手机支架  9: 桌面收纳盒  10: 护眼台灯  11: 静音小风扇  12: 移动硬盘 1TB

-- ------------------------------ 1）商品表 erp_list_product.company_product ------------------------------
USE `erp_list_product`;

UPDATE `company_product` SET `image_url` = 'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=400' WHERE `id` = 7;
UPDATE `company_product` SET `image_url` = 'https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?w=400' WHERE `id` = 8;
UPDATE `company_product` SET `image_url` = 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400' WHERE `id` = 9;
UPDATE `company_product` SET `image_url` = 'https://images.unsplash.com/photo-1507473885765-e6e407f36cbf?w=400' WHERE `id` = 10;
UPDATE `company_product` SET `image_url` = 'https://images.unsplash.com/photo-1585771724684-38269d4a029e?w=400' WHERE `id` = 11;
UPDATE `company_product` SET `image_url` = 'https://images.unsplash.com/photo-1597872200969-2b65d56bd3b6?w=400' WHERE `id` = 12;

-- ------------------------------ 2）订单明细表 erp_list_order.order_item（订单展示中的商品图） ------------------------------
USE `erp_list_order`;

UPDATE `order_item` SET `product_image` = 'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=400' WHERE `product_id` = 7;
UPDATE `order_item` SET `product_image` = 'https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?w=400' WHERE `product_id` = 8;
UPDATE `order_item` SET `product_image` = 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400' WHERE `product_id` = 9;
UPDATE `order_item` SET `product_image` = 'https://images.unsplash.com/photo-1507473885765-e6e407f36cbf?w=400' WHERE `product_id` = 10;
UPDATE `order_item` SET `product_image` = 'https://images.unsplash.com/photo-1585771724684-38269d4a029e?w=400' WHERE `product_id` = 11;
UPDATE `order_item` SET `product_image` = 'https://images.unsplash.com/photo-1597872200969-2b65d56bd3b6?w=400' WHERE `product_id` = 12;
