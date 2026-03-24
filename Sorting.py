# sorting.py
def bubble_sort(arr):
    """
    冒泡排序算法
    参数: arr - 待排序的列表
    返回: 排序后的列表
    """
    n = len(arr)
    for i in range(n):
        for j in range(0, n - i - 1):
            if arr[j] > arr[j + 1]:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]
    return arr


def quick_sort(arr):
    """
    快速排序算法
    参数: arr - 待排序的列表
    返回: 排序后的列表
    """
    if len(arr) <= 1:
        return arr
    pivot = arr[len(arr) // 2]
    left = [x for x in arr if x < pivot]
    middle = [x for x in arr if x == pivot]
    right = [x for x in arr if x > pivot]
    return quick_sort(left) + middle + quick_sort(right)


if __name__ == "__main__":
    # 测试代码
    test_list = [64, 34, 25, 12, 22, 11, 90]
    print("原始列表:", test_list)
    print("冒泡排序结果:", bubble_sort(test_list.copy()))
    print("快速排序结果:", quick_sort(test_list))