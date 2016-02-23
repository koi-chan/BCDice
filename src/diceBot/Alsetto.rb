#--*-coding:utf-8-*--

class Alsetto < DiceBot

  def initialize
    super
    @sortType = 1 #ダイスのソート有
  end


  def prefixs
    ['\d+ALC?(\d+)?(x|\*)\d+', '\d+ALC?(\d+)?']
  end

  def gameName
    '詩片のアルセット'
  end

  def gameType
    "Alsetto"
  end

  def getHelpMessage
    return <<MESSAGETEXT
・成功判定：[n]AL[X]　　　　・トライアンフ無し：[n]ALC[X]
・命中判定：[n]AL[X]*[p]　　・トライアンフ無し：[n]ALC[X]*[p]

ALコマンドはトライアンフの分だけ、自動で振り足し処理を行います。
「n」でダイス数を指定。必須。
「X」で目標値を指定。省略時は、デフォルトの「3」が使用されます。
「*[p]（x[p]）」を追記で攻撃力を指定。「*」と「x」のどちらでも可。
攻撃力指定で命中判定となり、成功数ではなく、ダメージを結果表示します。

ALCコマンドはトライアンフ無しで、成功数、ダメージを結果表示します。

【書式例】
・5AL → 5d6で目標値3。
・5ALC → 5d6で目標値3。トライアンフ無し。
・6AL2 → 6d6で目標値2。
・4AL*5 → 4d6で目標値3、攻撃力5の命中判定。
・7AL2x10 → 7d6で目標値2、攻撃力10の命中判定。
・8ALC4x5 → 8d6で目標値4、攻撃力5、トライアンフ無しの命中判定。
MESSAGETEXT
  end


  def rollDiceCommand(command)
    
    # ALCコマンド：命中判定
    # ALCコマンド：成功判定
    if /(\d+)AL(C)?(\d+)?((x|\*)(\d+))?$/i === command
      rapid = $1.to_i
      isCritical = $2.nil?
      target = ($3 || 3).to_i
      damage = ($6 || 0).to_i
      return checkRoll(rapid, target, damage, isCritical)
    end
    
    return nil
  end
  
  
  def checkRoll(rapid, target, damage, isCritical)
    totalSuccessCount = 0
    totalCriticalCount = 0
    text = ""
    
    rollCount = rapid
    
    while rollCount > 0
      dice, diceText = roll(rollCount, 6, @sortType)
      diceArray = diceText.split(/,/).collect{|i|i.to_i}

      successCount = 0
      criticalCount = 0
      
      diceArray.each do |i|
        if(i <= target)
          successCount += 1
        end
        
        if(i == 1)
          criticalCount += 1
        end
      end
      
      totalSuccessCount += successCount
      totalCriticalCount += criticalCount
      
      text += "+" unless( text.empty? )
      text += "#{successCount}[#{diceText}]"
      
      break unless( isCritical )
      
      rollCount = criticalCount
    end
    
    
    isDamage = (damage != 0)
    
    if( isDamage )
      totalDamage = totalSuccessCount * damage
      
      result = "(#{rapid}D6\<\=#{target}) ＞ #{text} ＞ Hits：#{totalSuccessCount}*#{damage} ＞ #{totalDamage}ダメージ"
      result += " / #{totalCriticalCount}トライアンフ" if( isCritical )
    else
      result = "(#{rapid}D6\<\=#{target}) ＞ #{text} ＞ 成功数：#{totalSuccessCount}"
      result += " / #{totalCriticalCount}トライアンフ" if( isCritical )
    end

    return result
  end
  
end
