import { KnowledgeItem } from '../model/KnowledgeItem'

function generateId(): string {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c: string) => {
    const r = Math.random() * 16 | 0
    const v = c === 'x' ? r : (r & 0x3 | 0x8)
    return v.toString(16)
  })
}

const PRESET_CARDS: KnowledgeItem[] = [
  new KnowledgeItem('', '乌鸦为什么像写字台？',
    '出自《爱丽丝梦游仙境》的经典谜题，谜面没有标准答案。作者卡罗尔在再版序言里补充了文字游戏：把 never 刻意拼成 nevar，倒过来就是 raven（乌鸦）；另有谐音逻辑——乌鸦能发出低沉声调，写字台能打出文字音符，二者都能"发出若干音调"。',
    '文学·冷知识', 'https://images.unsplash.com/photo-1552727456-7b0c4e3af3a5?w=600&h=400&fit=crop'),
  new KnowledgeItem('', '为什么臀部摸起来总是凉的？',
    '正常常温下人体臀部体表温度低于核心体温。原因是臀部脂肪层厚实、浅表血管分布较少，热量输送与循环较慢，加上久坐封闭环境易散热，所以触感偏凉。但直肠内肛温属于核心体温，可作为测温标准。',
    '人体·冷知识', 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=600&h=400&fit=crop'),
  new KnowledgeItem('', '人能咬断自己的手指吗？',
    '从生理咬合力来看，人类牙齿完全足以咬断自己的小拇指，硬度和断裂难度与胡萝卜相近。但大脑自带自我保护、疼痛预警与躯体抑制机制，会本能阻止自己对自身下狠手；面对他人肢体则无自我心理束缚，理论上可以咬断。',
    '人体·冷知识', 'https://images.unsplash.com/photo-1609840114035-3c981683ab9c?w=600&h=400&fit=crop'),
  new KnowledgeItem('', '鲎的血液为什么是蓝色的？',
    '鲎血含血蓝蛋白，蛋白中含铜元素，与氧气结合后呈独特的蓝色。鲎血遇细菌内毒素会快速凝固，利用此特性制成的鲎试剂广泛用于医疗器械、药品的细菌污染检测。长期过度采血与栖息地破坏，导致中国鲎现已成为濒危保护物种。',
    '生物·冷知识', 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600&h=400&fit=crop'),
  new KnowledgeItem('', '金和银是怎么来的？',
    '恒星内部核聚变到铁元素就达到比结合能峰值，无法继续聚变释能。原子序数大于铁的金、银、铀等所有重元素，基本都诞生于超新星爆发与中子星合并的快中子捕获过程，是宇宙高能事件的产物。',
    '天文·冷知识', 'https://images.unsplash.com/photo-1462331940025-496dfbfc7564?w=600&h=400&fit=crop'),
  new KnowledgeItem('', '苦瓜熟了其实是甜的',
    '日常吃的青苦瓜是未成熟果实，富含苦瓜苷，口感极苦。等苦瓜完全自然成熟后，外皮变为橙红色，种子包裹的假种皮变红，苦味物质逐步分解，糖分大量积累，成熟的果瓤吃起来是清甜口感。',
    '饮食·冷知识', 'https://images.unsplash.com/photo-1540420773422-607bb0fc2da3?w=600&h=400&fit=crop'),
  new KnowledgeItem('', '匈牙利人姓名和中国一样先姓后名',
    '匈牙利人姓名沿用东方语序习惯，先姓氏、后名字，和中国完全一致，与欧美先名后姓完全相反。如著名诗人裴多菲·山多尔，裴多菲是家族姓氏，山多尔是个人名字。',
    '文化·冷知识', 'https://images.unsplash.com/photo-1519999482643-697aff486426?w=600&h=400&fit=crop'),
  new KnowledgeItem('', '100℃煮尸体为什么破坏不了DNA？',
    '日常烧水、烹煮100℃左右的温度根本无法破坏人体DNA结构，骨组织与深层软组织里的DNA仍能完整保留，法医依旧可以提取鉴定。只有焚化炉1000℃以上高温长时间灼烧，才能彻底降解破坏DNA。',
    '法医·冷知识', 'https://images.unsplash.com/photo-1532187860701-2c8c4e6c8a6f?w=600&h=400&fit=crop'),
  new KnowledgeItem('', '肛门皮肤和嘴唇其实高度相似',
    '肛门周边皮肤和嘴唇表层组织，同属于人体复层扁平上皮，基础组织结构高度相似。区别在于肛周皮肤角质层更厚偏耐磨，嘴唇角质层薄更柔嫩，功能与外在形态差异明显。',
    '人体·冷知识', 'https://images.unsplash.com/photo-1494790108377-fe9e5b2d5314?w=600&h=400&fit=crop'),
  new KnowledgeItem('', '你身体里的铁和钙来自星星',
    '人体构成所需的铁、钙、锌、磷等几乎所有微量元素，全部来自远古超新星爆发与中子星合并锻造出的重元素。从科学层面来说，人体本身就是星尘构成的。',
    '天文·冷知识', 'https://images.unsplash.com/photo-1419242902214-272b3e66e7e7?w=600&h=400&fit=crop'),
  new KnowledgeItem('', '全身麻醉不是深度睡觉',
    '手术全身麻醉是通过麻醉药物强制抑制人体整个中枢神经系统，让人彻底丧失意识、痛觉与躯体反射能力。麻醉状态下人体会失去自主呼吸功能，必须依靠呼吸机辅助维持呼吸和供氧。',
    '医学·冷知识', 'https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=600&h=400&fit=crop'),
  new KnowledgeItem('', '台风的名字是怎么来的？',
    '台风命名由世界气象组织亚太14个成员国和地区各自提供10个名字，共140个名字按顺序循环轮换使用。若某台风造成特大人员伤亡、毁灭性财产损失，就会被永久除名不再复用，由原提供国重新补充新名字替补。',
    '自然·冷知识', 'https://images.unsplash.com/photo-1527482798492-4b2c1e2a3b4c?w=600&h=400&fit=crop'),
  new KnowledgeItem('', '青蛙会把整个胃翻出来清洗',
    '青蛙没有人类的呕吐反射机制，无法像普通动物一样直接呕吐。当误食有毒或无法消化的食物时，会把整个胃部从口腔外翻出来，用前肢清理掉胃里杂物，再将胃部复位回体内。',
    '生物·冷知识', 'https://images.unsplash.com/photo-1559253668-1a72a0be8d21?w=600&h=400&fit=crop'),
  new KnowledgeItem('', '章鱼有三颗心脏',
    '章鱼天生拥有三颗心脏：两颗鳃心专门为鳃部供血，一颗主心脏为全身躯体供血。当章鱼喷水游泳时，主心脏会暂时停止跳动，体能消耗极大极易疲惫，所以章鱼大多时间更喜欢在海底爬行，很少长距离游泳。',
    '生物·冷知识', 'https://images.unsplash.com/photo-1565689861316-1b6e4bbbb15f?w=600&h=400&fit=crop'),
  new KnowledgeItem('', '毛毛虫化蝶是彻底打散重组',
    '进入蛹期后，毛毛虫体内绝大部分肌肉、器官组织会被酶溶解成液态细胞浆液，只保留少量成虫盘干细胞。再由这些干细胞重新分裂、分化、组装，完整重构出蝴蝶的翅膀、触角、肢体等全新躯体结构。',
    '生物·冷知识', 'https://images.unsplash.com/photo-1535573235554-3b98e3b34a0a?w=600&h=400&fit=crop'),
  new KnowledgeItem('', '老年痴呆和癌症几乎"互斥"',
    '阿尔茨海默病是脑细胞过度凋亡衰退，癌症是细胞无限增殖失控。二者并非绝对互斥，但流行病学统计显示，患老年痴呆的人群癌症发病概率明显低于普通人群，二者存在发病机制反向特征。',
    '医学·冷知识', 'https://images.unsplash.com/photo-1559757148-3b4f81b89927?w=600&h=400&fit=crop'),
  new KnowledgeItem('', '地球上的水可能来自彗星',
    '主流假说认为地球早期地表缺水，现存的大量水分主要由远古彗星与含水小行星不断撞击地球带入并留存，逐步形成海洋与水系。此为学界主流推测，尚未被完全证实。',
    '科学假说', 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=600&h=400&fit=crop'),
  new KnowledgeItem('', '打嗝是远古两栖类的进化遗迹',
    '学界推测打嗝时膈肌突然收缩、声门瞬间关闭的动作模式，与远古两栖类蝌蚪用鳃呼吸的生理动作高度吻合，大概率是进化过程中保留下来的原始呼吸反射残留。此为推测，尚未完全证实。',
    '科学假说', 'https://images.unsplash.com/photo-1587588353454-c2cb7e7e1e4?w=600&h=400&fit=crop')
]

export class FallbackData {
  static getRandomCard(): KnowledgeItem {
    const idx = Math.floor(Math.random() * PRESET_CARDS.length)
    const src = PRESET_CARDS[idx]
    const card = new KnowledgeItem(generateId(), src.title, src.content, src.category, src.imageUrl)
    card.source = 'local'
    return card
  }

  static getAll(count: number = 5): KnowledgeItem[] {
    const result: KnowledgeItem[] = []
    const indices = PRESET_CARDS.map((_: KnowledgeItem, i: number) => i).sort(() => Math.random() - 0.5)
    const limit = Math.min(count, indices.length)
    for (let i = 0; i < limit; i++) {
      const src = PRESET_CARDS[indices[i]]
      const card = new KnowledgeItem(generateId(), src.title, src.content, src.category, src.imageUrl)
      card.source = 'local'
      result.push(card)
    }
    return result
  }
}
