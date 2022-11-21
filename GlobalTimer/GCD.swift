//
//  GCD.swift
//  HiPOSHD_iPad
//
//  Created by 马冰垒 on 2022/8/31.
//  Copyright © 2022 bingleima@qq.com. All rights reserved.
//

import Foundation

class GCD {
    /// 获取两个数的最大公约数
    class func gcd(_ a: UInt, _ b: UInt) -> UInt {
        return b == 0 ? a : gcd(b, a % b)
    }
    
    /// 获取最大公约数
    class func gcd(_ nums: [UInt]) -> UInt {
        guard nums.count > 1 else { return nums.first ?? 0 }
        var result = nums.first!
        for i in 1..<nums.count {
            result = gcd(result, nums[i])
        }
        return result
    }
}
