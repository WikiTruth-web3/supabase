# Trigger

## box_user_order_amounts
表示某个box中某个用户当前的订单资金

### 1. 增加 currentAmount
监听：payments表，
特殊条件：pay_type === 'OrderAmount'。

### 2. 清零 currentAmount
监听：order_refund_withdraws表，
特殊条件：无（任何类型都会触发清零）。

## box_rewards
记录box产生的奖励总数

### 1. 增加 totalAmount
监听：rewards_addeds表，
特殊条件：无

> 这个表的资金只有增加，不会减少

## user_rewards
记录用户获得的奖励

### 1. 增加 currentAmount, totalAmount
监听：rewards_addeds表，
特殊条件：无。

### 2. 清零 currentAmount
监听：rewards_withdraws表，
特殊条件：无（任何类型都会触发清零）。

> totalAmount 不会清零，它是记录总数的字段

## token_total_amounts

记录合约中所有资金类型总数

### 1. 增加 amount
监听：payments、order_refund_withdraws、rewards_addeds、 rewards_withdraws，
特殊条件：无。

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