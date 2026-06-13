# Trigger

## box_user_order_amounts
表示某个box中某个用户当前的订单资金

### 1. 增加 currentAmount
监听：payments，
过滤条件：pay_type === 'OrderAmount'。
表示：支付了订单资金，则记录该box，该用户当前所累积的订单资金。

### 2. 清零 currentAmount
监听1：order_refund_withdraws，
过滤条件：无（任何类型都会触发清零）。
表示：user提取了订单/退款资金，那么就要将订单金额清零。

监听2：rewards_addeds，
过滤条件：无（任何类型都会触发清零）。
目标：boxes表的 buyer_id.
表示：该box发出奖励，那么就要将该box的buyer的订单金额清零。

## box_rewards
记录box产生的奖励总数

### 1. 增加 totalAmount
监听：rewards_addeds，
过滤条件：无
表示：该box中用户所累积的奖励总数

> 这个表的资金只有增加，不会减少

## user_rewards
记录用户获得的奖励

### 1. 增加 currentAmount, totalAmount
监听：rewards_addeds，
过滤条件：无。
表示：某个用户当前的奖励和累积奖励。

### 2. 清零 currentAmount
监听：rewards_withdraws，
过滤条件：无（任何类型都会触发清零）。
表示：用户提取奖励后，当前（可提取）的奖励被清零。

> totalAmount 不会清零，它是记录总数的字段

## token_total_amounts

记录合约中所有资金类型总数

### 1. 增加 amount
监听：payments、order_refund_withdraws、rewards_addeds、 rewards_withdraws，

计算方式： payments表依据类型分别增加'PaymentOrder'和'PaymentDelayFee'。
          order_refund_withdraws表依据类型分布增加：'OrderWithdraw'和'RefundWithdraw', 
          rewards_addeds表 增加'RewardAdded'
          rewards_withdraws表增加'RewardWithdraw'

> 这是一个计算总数的表，只会增加，不会减少。

## box_status_statistical
统计box status的数据

```solidity
enum BoxStatus {
    Storing, // 0
    Selling, 
    Auctioning,
    Paid,
    Delaying,
    Refunding, 
    Published,
    Blacklisted
}
```
监听：boxes表的status字段
创建时：对应的值 + 1 
更新时：旧值-1，新值+1

> 合约中，创建box，status为 Storing，或Published.